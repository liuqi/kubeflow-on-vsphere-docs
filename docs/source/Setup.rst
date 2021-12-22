Setup
=====

Prerequisite
------------

vSphere with Tanzu Deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

(Optional, XXX) You may need to patch API server and set docker hub credentials

:download:`A script <tkg.zsh>` is also provided to perform the above jobs.

Project Thunder Deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploy other Kubernetes Platforms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use `Installing a cluster on vSphere <https://docs.openshift.com/container-platform/4.8/installing/installing_vsphere/installing-vsphere-installer-provisioned.html>`_ and this page to deploy OpenShift.

#. Networking requirements

   * The API address is used to access the cluster API. ``api.ocp4-cluster-001.liuqi.io 10.105.136.130``
   * The Ingress address is used for cluster ingress traffic. ``*.apps.ocp4-cluster-001.liuqi.io 10.105.136.131``

#. Generating install-config.yaml

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

#. Modify install-config.yaml to add proxy configuration

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

#. Deploy the cluster

   .. code-block:: bash
      :linenos:

      # Deploy the cluster according to install-config.yaml
      # --dir must be the one where the install-config.yaml file is located
      openshift-install create cluster --dir /home/redcloud/ipi/ipi/

#. Following `Creating registry storage <https://docs.openshift.com/container-platform/4.6/registry/configuring_registry_storage/configuring-registry-storage-vsphere.html>`_ to finish storage configuration.

#. Test the cluster

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

#. Test proxy

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

#. How to ssh to othe node once the cluster is success.

   .. code-block:: bash
      :linenos:

      # ssh -i ssh-key/id_rsa core@<OC-NODE>
      ssh -i /root/.ssh/test_rsa core@10.105.137.224

.. seealso::

   - `Red Hat OpenShift Container Platform 4.3 (OCP) <Red Hat OpenShift Container Platform 4.3 (OCP)>`_
   - `Installing a cluster on vSphere <https://docs.openshift.com/container-platform/4.8/installing/installing_vsphere/installing-vsphere-installer-provisioned.html>`_
   - `How to ssh to other openshift node? <https://blog.csdn.net/weixin_43902588/article/details/115432124>`_
   - `After installing OpenShift 4.x, what need to do if SSH keys are not copied to the nodes? <https://access.redhat.com/solutions/4725001>`_
   - `Create Users on OpenShift 4 <https://medium.com/kubelancer-private-limited/create-users-on-openshift-4-dc5cfdf85661>`_

Deploy on vSphere with Tanzu
----------------------------

#. Use the following commands to set the default storage class. Skip this step if the default storage class has been set.

   .. code-block:: console
      :linenos:

      # https://anthonyspiteri.net/tanzu-no-default-storageclass/
      $ kubectl config use-context liuqi
      $ kubectl edit tanzukubernetescluster tkgs-cluster-16
      # add the following content under spec/settings (same level as network setting)
      ...
      storage:
        defaultClass: pacific-storage-policy
      ...
      $ kubectl config use-context tkgs-cluster-16
      $ kubectl get sc

#. Use the following commands to add the fstype parmeter to workaround PVC issue. Skip this step if this has been done.

   .. code-block:: console
      :linenos:

      # https://bugzilla.eng.vmware.com/show_bug.cgi?id=2764622
      $ kubectl vsphere login --server=10.117.233.1 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify --tanzu-kubernetes-cluster-namespace=liuqi --tanzu-kubernetes-cluster-name=tkgs-cluster-33
      $ kubectl get sc pacific-storage-policy -o yaml > tmp-sc.yaml
      $ sed '/^parameters:.*/a\ \ csi.storage.k8s.io/fstype: "ext4"' -i tmp-sc.yaml
      $ kubectl replace -f tmp-sc.yaml --force

#. Patch PSP

   .. code-block:: console
      :linenos:

      $ cat << EOF | kubectl apply -f -
      apiVersion: v1
      kind: Namespace
      metadata:
        name: auth
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-auth
        namespace: auth
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:auth
      ---
      apiVersion: v1
      kind: Namespace
      metadata:
        name: cert-manager
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-cert-manager
        namespace: cert-manager
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:cert-manager
      ---
      apiVersion: v1
      kind: Namespace
      metadata:
        name: istio-system
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-istio-system
        namespace: istio-system
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:istio-system
      ---
      apiVersion: v1
      kind: Namespace
      metadata:
        name: knative-serving
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-knative-serving
        namespace: knative-serving
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:knative-serving
      ---
      apiVersion: v1
      kind: Namespace
      metadata:
        name: kubeflow
        labels:
          control-plane: kubeflow
          istio-injection: enabled
      ---
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-kubeflow
        namespace: kubeflow
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:kubeflow
      EOF

#. Deploy Kubeflow step by step using the note `here <https://github.com/kubeflow/manifests/tree/v1.4-branch#install-individual-components>`_

#. Fix PSP issues for example namespace

   .. code-block:: console
      :linenos:

      $ cat << EOF | kubectl apply -f -
      kind: RoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: rb-all-sa_ns-kubeflow-user-example-com
        namespace: kubeflow-user-example-com
      roleRef:
        kind: ClusterRole
        name: psp:vmware-system-privileged
        apiGroup: rbac.authorization.k8s.io
      subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: system:serviceaccounts:kubeflow-user-example-com
      EOF

Deploy with Kubernetes Operator
-------------------------------

Deploy with Supervisor Services on vSphere with Tanzu
-----------------------------------------------------

Deploy on other Kubernetes Platform
-----------------------------------

.. seealso::

   `Kubeflow 1.4 Installing on OpenShift <https://v1-3-branch.kubeflow.org/docs/distributions/openshift/install-kubeflow/>`_

Check kubeflow requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Code Ready Containers Resources:
If you are using Code Ready Containers, you need to make sure you have enough resources configured for the VM:

.. code-block:: console
   :linenos:

   # Recommended: (to check every openshift node resouces.)
   16 GB memory
   6 CPU
   45 GB disk space


   # Minimal:
   10 GB memory
   6 CPU
   30 GB disk space (default for CRC)

Workflow to deploy Kubeflow on OpenShift
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Please read Kubeflow Installing on OpenShift this websit and this page to deploy OpenShift**

#. Clone the `opendatahub/manifests <https://github.com/opendatahub-io/manifests>`_ repository. This repository defaults to the v1.3-branch-openshift branch. But we need to deploy kubeflow 1.4 and there is no v1.4-branch kubeflow branch，so you need to `yourself kubeflow 1.4 repo <https://github.com/AmyHoney/kubeflow-1.4>`_.

   .. code-block:: console
      :linenos:

      git clone https://github.com/AmyHoney/kubeflow-1.4
      cd manifests

#. Build the deployment configuration using the OpenShift KFDef file and local downloaded manifests

   .. code-block:: console
      :linenos:

      # update the manifest repo URI
      sed -i 's#uri: .*#uri: '$PWD'#' ./kfdef/kfctl_openshift.yaml

      # set the Kubeflow application diretory for this deployment, for example /opt/openshift-kfdef
      export KF_DIR=<path-to-kfdef>
      mkdir -p ${KF_DIR}
      cp ./kfdef/kfctl_openshift.yaml ${KF_DIR}

      # build deployment configuration
      cd ${KF_DIR}

      [vcp@mlops-oss openshift-kfdef]$ kfctl build --file=kfctl_openshift.yaml
      [vcp@mlops-oss openshift-kfdef]$ ls
      kfctl_openshift.yaml  kustomize

#. Apply the generated deployment configuration.

   .. code-block:: console
      :linenos:

      kfctl apply --file=kfctl_openshift.yaml

#. Wait until all the pods are running in kubeflow namespace.

   .. code-block:: console
      :linenos:

      oc get pods -n kubeflow
      NAME                                                           READY   STATUS    RESTARTS   AGE
      argo-ui-7f79c9ccbc-vxqgx                                       1/1     Running   0          7m55s
      centraldashboard-65d87fb769-d8l5g                              1/1     Running   0          7m55s
      jupyter-web-app-deployment-6748fc47cc-78hr4                    1/1     Running   0          7m
      katib-controller-7dd757bdf-wmg2t                               1/1     Running   1          6m57s
      .......

#. The command below looks up the URL of the Kubeflow user interface assigned by the OpenShift cluster. You can open the printed URL in your browser to access the Kubeflow user interface.

    .. code-block:: console
       :linenos:

       # get kubeflow ui website as follow
       oc get routes -n istio-system istio-ingressgateway -o jsonpath='http://{.spec.host}/'
       http://istio-ingressgateway-istio-system.apps.ocp4-cluster-001.liuqi.io/

.. seealso::

   - `Kubeflow 1.4 gitlab code <https://github.com/AmyHoney/kubeflow-1.4>`_
   - `Set openshift proxy <https://access.redhat.com/documentation/zh-cn/openshift_container_platform/3.11/html/installing_clusters/setting-proxy-overrides>`_

Security
--------

Storage
-------

Network
-------
