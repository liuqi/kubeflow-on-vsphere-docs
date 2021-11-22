Prerequisite
============

OpenShift Deployment (Yajing)
-----------------------------

.. seealso::
    
    `Installing a cluster on vSphere <https://docs.openshift.com/container-platform/4.8/installing/installing_vsphere/installing-vsphere-installer-provisioned.html>`_

Networking requirements: Required IP Addresses
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. The API address is used to access the cluster API. ``api.ocp4-cluster-001.liuqi.io 10.105.136.130``
2. The Ingress address is used for cluster ingress traffic. ``*.apps.ocp4-cluster-001.liuqi.io 10.105.136.131``

Workflow to deploy OpenShift 4.8 via IPI on vSphere
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
**Please read Installing a cluster on vSphere this website and this page to deploy OpenShift**

1. Generating install-config.yaml

.. code-block:: bash
    :linenos:

    # Generating install-config.yaml
    openshift-install create install-config --dir=ipi
    ? SSH Public Key <none>
    ? Platform vsphere
    ? vCenter sha1-skevin-vc01.eng.vmware.com
    ? Username administrator@vsphere.local
    ? Password [? for help] ********
    INFO Connecting to vCenter sha1-skevin-vc01.eng.vmware.com
    INFO Defaulting to only available datacenter: VCP
    INFO Defaulting to only available cluster: WCP-Cluster
    ? Default Datastore vsanDatastore
    ? Network VM Network 136
    ? Virtual IP Address for API [? for help] 10.105.136.130      #API address
    ? Virtual IP Address for Ingress [? for help] 10.105.136.131  #Ingress address
    ? Base Domain liuqi.io
    ? Cluster Name ocp4-cluster-001
    ? Pull Secret [? for help]

2. Modify install-config.yaml to add proxy configuration

  There is a example of `install-config.yaml <https://gitlab.eng.vmware.com/vcp/oss-mlops/-/blob/master/install-config.yaml>`_

.. code-block:: bash
    :linenos:

    apiVersion: v1
    baseDomain: liuqi.io
    proxy:  # add proxy configuration
      httpProxy: http://proxy.vmware.com:3128
      httpsProxy: http://proxy.vmware.com:3128
      noProxy: .cluster.local,.svc,10.105.136.0/23,127.0.0.1,172.30.0.0/16,20.128.0.0/14,api-int.ocp4-cluster-001.liuqi.io,liuqi.io,localhost
    compute:
    - architecture: amd64
      hyperthreading: Enabled
      name: worker

3. Deploy the cluster

.. code-block:: bash
    :linenos:
 
    # Deploy the cluster according to install-config.yaml
    # --dir must be the one where the install-config.yaml file is located
    openshift-install create cluster --dir /home/redcloud/ipi/ipi/

4. Following `Creating registry storage <https://docs.openshift.com/container-platform/4.6/registry/configuring_registry_storage/configuring-registry-storage-vsphere.html>`_ to finish storage configuration.

5. Test the cluster

* Using Openshift CLI access the cluster as the system:admin user when using ``oc``, run ``export KUBECONFIG=<installation_directory>/auth/kubeconfig``

.. code-block:: bash
    :linenos:
    
    #check if all nodes are ready
    oc get nodes
    #check if all pods are running or completed 
    oc get pods -A
    #check if all clusteroperators are running
    oc get co

* Access the OpenShift web-console here: https://console-openshift-console.apps.ocp4-cluster-001.liuqi.io; user is kubeadmin, and password is stored in the dir <installation_directory>/auth/kubeadmin-password.

6. Test proxy

.. code-block:: bash
    :linenos:

    # create a new project
    oc new-project zyajing-proj
    # create pod in this new project and pull image from google repo
    kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname -n zyajing-proj
    #if pod is running, that mean proxy configuration is success.
    oc get pod -n zyajing-proj
    NAME                              READY   STATUS    RESTARTS   AGE
    pod/hello-node-7999f8f5bb-thswn   1/1     Running   0          11s

7. How to ssh to othe node once the cluster is success.

.. code-block:: bash
    :linenos:

    # ssh -i ssh-key/id_rsa core@<OC-NODE>
    ssh -i /root/.ssh/test_rsa core@10.105.137.224

Reference

.. seealso::

    - `Red Hat OpenShift Container Platform 4.3 (OCP) <Red Hat OpenShift Container Platform 4.3 (OCP)>`_
    - `Installing a cluster on vSphere <https://docs.openshift.com/container-platform/4.8/installing/installing_vsphere/installing-vsphere-installer-provisioned.html>`_
    - `How to ssh to other openshift node? <https://blog.csdn.net/weixin_43902588/article/details/115432124>`_
    - `After installing OpenShift 4.x, what need to do if SSH keys are not copied to the nodes? <https://access.redhat.com/solutions/4725001>`_
    - `Create Users on OpenShift 4 <https://medium.com/kubelancer-private-limited/create-users-on-openshift-4-dc5cfdf85661>`_

vSphere with Tanzu Deployment
-----------------------------
From `Kubeflow documentation <https://github.com/kubeflow/manifests/tree/v1.4-branch#prerequisites>`_, the prerequisties for Kubeflow 1.4 installation are

- ``Kubernetes`` (tested with version ``1.19``) with a default ``StorageClass``
- ``kustomize`` (version ``3.2.0``)
- ``kubectl``

The following is an example to deploy TKG cluster v1.19 on vSphere with Tanzu.

.. code-block:: console
    :linenos:

    # Create a new tkg cluster
    $ kubectl vsphere login --server=10.117.233.1 \
       --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
    $ kubectl config use-context liuqi
    $ cat << EOF | kubectl apply -f -
    apiVersion: run.tanzu.vmware.com/v1alpha1
    kind: TanzuKubernetesCluster
    metadata:
      name: tkgs-cluster-2                     # cluster name, user defined
      namespace: liuqi                         # vsphere namespace
    spec:
      distribution:
        version: v1.19                         # resolves to latest TKG 1.19
      topology:
        controlPlane:
          count: 1                             # number of control plane nodes
          class: best-effort-medium            # vmclass for control plane nodes
          storageClass: pacific-storage-policy # storageclass for control plane
        workers:
          count: 7                             # number of worker nodes
          class: best-effort-medium            # vmclass for worker nodes
          storageClass: pacific-storage-policy # storageclass for worker nodes
    EOF

    # Wait for the cluster ready
    $ kubectl get tanzukubernetesclusters

.. note::
   Refer to the following document to synchronize the local content library for TKG v1.19

   `Create, Secure, and Synchronize a Local Content Library for Tanzu Kubernetes releases <https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-E8C37D8A-E261-44F0-9947-45ABAB526CF3.html>`_

Use the following commands to patch API server and set docker hub credentials

XXX

A script is also provided to perform the above jobs.

Project Thunder Deployment
--------------------------
