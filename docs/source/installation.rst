Kubeflow Installation
=====================

Deploy on OpenShift (Yajing)
----------------------------
.. seealso::
    
    `Kubeflow 1.4 Installing on OpenShift <https://v1-3-branch.kubeflow.org/docs/distributions/openshift/install-kubeflow/>`_

Check kubeflow requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Code Ready Containers Resources: 
If you are using Code Ready Containers, you need to make sure you have enough resources configured for the VM:

.. code-block:: bash
    :linenos:

    #Recommended: （to check every openshift node resouces.）
    16 GB memory
    6 CPU
    45 GB disk space


    #Minimal:
    10 GB memory
    6 CPU
    30 GB disk space (default for CRC)

Workflow to deploy Kubeflow on OpenShift
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
**Please read Kubeflow Installing on OpenShift this websit and this page to deploy OpenShift**

1. Clone the `opendatahub/manifests <https://github.com/opendatahub-io/manifests>`_ repository. This repository defaults to the v1.3-branch-openshift branch. But we need to deploy kubeflow 1.4 and there is no v1.4-branch kubeflow branch，so you need to `yourself kubeflow 1.4 repo <https://github.com/AmyHoney/kubeflow-1.4>`_.

.. code-block:: bash
    :linenos:

    git clone https://github.com/AmyHoney/kubeflow-1.4
    cd manifests

2. Build the deployment configuration using the OpenShift KFDef file and local downloaded manifests

.. code-block:: bash
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
 
3. Apply the generated deployment configuration.

.. code-block:: bash
    :linenos:

    kfctl apply --file=kfctl_openshift.yaml

4. Wait until all the pods are running in kubeflow namespace.

.. code-block:: bash
    :linenos:

    oc get pods -n kubeflow
    NAME                                                           READY   STATUS    RESTARTS   AGE
    argo-ui-7f79c9ccbc-vxqgx                                       1/1     Running   0          7m55s
    centraldashboard-65d87fb769-d8l5g                              1/1     Running   0          7m55s
    jupyter-web-app-deployment-6748fc47cc-78hr4                    1/1     Running   0          7m
    katib-controller-7dd757bdf-wmg2t                               1/1     Running   1          6m57s
    .......

5. The command below looks up the URL of the Kubeflow user interface assigned by the OpenShift cluster. You can open the printed URL in your browser to access the Kubeflow user interface.

.. code-block:: bash
    :linenos:

    # get kubeflow ui website as follow
    oc get routes -n istio-system istio-ingressgateway -o jsonpath='http://{.spec.host}/'
    http://istio-ingressgateway-istio-system.apps.ocp4-cluster-001.liuqi.io/

Reference

.. seealso::

    - `Kubeflow 1.4 gitlab code <https://github.com/AmyHoney/kubeflow-1.4>`_
    - `Set openshift proxy <https://access.redhat.com/documentation/zh-cn/openshift_container_platform/3.11/html/installing_clusters/setting-proxy-overrides>`_

Deploy on vSphere with Tanzu (Qi)
---------------------------------

Use the following commands to set the default storage class. Skip this step if the
default storage class has been set.

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

Use the following commands to add the fstype parmeter to workaround PVC issue.
Skip this step if this has been done.

.. code-block:: console
    :linenos:

    # https://bugzilla.eng.vmware.com/show_bug.cgi?id=2764622
    $ kubectl vsphere login --server=10.117.233.1 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify --tanzu-kubernetes-cluster-namespace=liuqi --tanzu-kubernetes-cluster-name=tkgs-cluster-33
    $ kubectl get sc pacific-storage-policy -o yaml > tmp-sc.yaml
    $ sed '/^parameters:.*/a\ \ csi.storage.k8s.io/fstype: "ext4"' -i tmp-sc.yaml
    $ kubectl replace -f tmp-sc.yaml --force

