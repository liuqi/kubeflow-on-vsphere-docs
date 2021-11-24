#!/bin/zsh

number=34

export PATH=/home/liuqi/00-kubectl-vsphere-plugin/bin:$PATH
export KUBECTL_VSPHERE_PASSWORD="Admin!23"

kubectl vsphere login --server=10.117.233.1 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
kubectl config use-context liuqi

# create tkg cluster
cat << EOF | kubectl apply -f -
apiVersion: run.tanzu.vmware.com/v1alpha1  #TKGS API endpoint
kind: TanzuKubernetesCluster               #required parameter
metadata:
  name: tkgs-cluster-$number               #cluster name, user defined
  namespace: liuqi                         #vsphere namespace
spec:
  distribution:
    version: v1.19                         #Resolves to latest TKR 1.19 version
  topology:
    controlPlane:
      count: 1                             #number of control plane nodes
      class: best-effort-medium            #vmclass for control plane nodes
      storageClass: pacific-storage-policy     #storageclass for control plane
    workers:
      count: 7                             #number of worker nodes
      class: best-effort-medium            #vmclass for worker nodes
      storageClass: pacific-storage-policy     #storageclass for worker nodes
  settings:
    storage:
      defaultClass: pacific-storage-policy
    network:
      proxy:
        httpProxy: http://proxy.liuqi.io:3128  #Proxy URL for HTTP connections
        httpsProxy: http://proxy.liuqi.io:3128 #Proxy URL for HTTPS connections
        noProxy: [10.244.0.0/20,10.117.233.0/26,10.117.233.64/26,192.168.0.0/16,10.0.0.0/8,127.0.0.1,localhost,.svc,.svc.cluster.local] #SVC Pod, Egress, Ingress CIDRs
EOF

while true; do
  kubectl get tanzukubernetesclusters|grep tkgs-cluster-$number|grep running
  if [[ $? == 0 ]]; then
    break
  fi
  sleep 30
  echo "Wait tkg cluster provision finish..."
done

# get ssh password
kubectl config use-context 10.117.233.1
ssh_password=`kubectl get secret tkgs-cluster-$number-ssh-password -o jsonpath='{.data.ssh-passwordkey}' -n liuqi| base64 -d`
echo $ssh_password

kubectl config use-context liuqi
control_vm_ip=`kubectl describe virtualmachines tkgs-cluster-$number-control-plane|grep "Vm Ip"|cut -d: -f2 -|sed 's/^[ \t]*//g' -`
echo "Control Plane Node IP is "$control_vm_ip
nodes_ip=`kubectl describe virtualmachines tkgs-cluster-$number-workers|grep "Vm Ip"|cut -d: -f2 -|sed 's/^[ \t]*//g' -`

# patch api-server (control node)
kubectl config use-context liuqi
kubectl exec ubuntu2 -- bash -c "\
{
ssh_password=$ssh_password
for node in ${control_vm_ip}; do
  "'#use inner variable substitution
    sshpass -p $ssh_password ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HashKnownHosts=no vmware-system-user@$node \
    '\''apiServerFile=/etc/kubernetes/manifests/kube-apiserver.yaml; \
    sudo sed -i "s,- --tls-private-key-file=/etc/kubernetes/pki/apiserver.key,- --tls-private-key-file=/etc/kubernetes/pki/apiserver.key\n\    - --service-account-issuer=kubernetes.default.svc\n\    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key," $apiServerFile '\''
  '"
done;
}"

# for each node
echo "${nodes_ip}" | while read -r nodes; do
  echo $nodes
  echo "===="
  kubectl exec ubuntu2 -- bash -c "\
  {
  ssh_password=$ssh_password
  for node in ${nodes}; do
    "'
      sshpass -p $ssh_password scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HashKnownHosts=no config.json vmware-system-user@$node:~
    '"
  done;
  }"

  kubectl exec ubuntu2 -- bash -c "\
  {
  ssh_password=$ssh_password
  for node in ${nodes}; do
    "'
      sshpass -p $ssh_password ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HashKnownHosts=no vmware-system-user@$node '\'' sudo mv config.json /var/lib/kubelet/ '\''
    '"
  done;
  }"
done

exit

# login and collect vm ips
kubectl vsphere login --server=10.117.233.1 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
kubectl config use-context liuqi

nodes_ip=`kubectl describe virtualmachines tkgs-cluster-18-workers|grep "Vm Ip"|cut -d: -f2 -|sed 's/^[ \t]*//g' -`
# echo $nodes_ip

echo "${nodes_ip}" | while read -r node; do
  echo $node
  echo "===="
done
