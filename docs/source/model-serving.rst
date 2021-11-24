Model Serving (Harper)
======================

.. seealso::

   `Link to the KFServing summary notes <https://dashing-axolotl-95d.notion.site/KFServing-98ca85ba483841cc84697512fffef916>`_


3.1 Model Serving Basics
------------------------

3.1.1 Background
++++++++++++++++

[To do]

3.1.2 Overview
+++++++++++++++

.. figure:: ./figs/model-serving-architecture.png
   :width: 1024
   :scale: 50%
   :align: center

   Figure 1 - The Workflow of Model Serving.

[To do]

3.2 KServe Basics
-----------------

3.2.1 The Overview of Kserve
++++++++++++++++++++++++++++

KServe is a standard Model Inference Platform on Kubernetes, built for highly scalable use cases. KServe provides a Kubernetes Custom Resource Definition for 
serving machine learning (ML) models on arbitrary frameworks. It encapsulates the complexity of autoscaling, networking, health checking, 
and server configuration to bring cutting edge serving features like GPU Autoscaling, Scale to Zero, and Canary Rollouts to your ML deployments.

.. figure:: ./figs/kserve-overview.png
   :width: 1024
   :scale: 60%
   :align: center

   Figure 2 - The Overview of Kserve.

3.2.2 The Architecture of Kserve
++++++++++++++++++++++++++++++++

[To do]

Control Plane
^^^^^^^^^^^^^

Responsible for reconciling the InferenceService custom resources. It creates the Knative serverless deployment for predictor, transformer, explainer to 
enable autoscaling based on incoming request workload including scaling down to zero when no traffic is received.

.. figure:: ./figs/control-plane.png
   :width: 1000
   :scale: 70%
   :align: center

   Figure 3 - The Control Plane of Kserve.

Data Plane
^^^^^^^^^^^^

The Kserve data plane architecture is described as figure 4. 

.. figure:: ./figs/data-plane.png
   :width: 800
   :scale: 70%
   :align: center

   Figure 4 - The Data Plane of Kserve.

* Endpoint: InferenceServers are divided into two endpoints: "default" and "canary". The endpoints allow users to safely make changes using the Pinned and Canary rollout strategies

* Component: Each endpoint is composed of multiple components: "predictor", "explainer", and "transformer". The only required component is the predictor, which is the core of the system

* Predictor: The predictor is the workhorse of the InferenceService. It is simply a model and a model server that makes it available at a network endpoint

* Explainer: The explainer enables an optional alternate data plane that provides model explanations in addition to predictions. KFServing provides out-of-the-box explainers like Alibi.

* Transformer: The transformer enables users to define a pre and post processing step before the prediction and explanation workflows. KFServing provides out-of-the-box transformers like Feast


3.2.3 KServe's Services and Features [To do]
++++++++++++++++++++++++++++++++++++++++++++

Single Model Serving
^^^^^^^^^^^^^^^^^^^^

Multi Model Serving
^^^^^^^^^^^^^^^^^^^^

Deploy InferenceService with Transformers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploy InferenceService with Explainer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploy InferenceService with storage
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Model Monitoring
^^^^^^^^^^^^^^^^

Autoscaling
^^^^^^^^^^^

Request Batching
^^^^^^^^^^^^^^^^

Payload Logging
^^^^^^^^^^^^^^^

Kafka
^^^^^


3.2 KServe Using
----------------

3.2.1 Environments
++++++++++++++++++

.. csv-table:: Table 1: Environment settings
   :header: "Cluster", "Kubeflow", "KFServing", "Demo Link" 
   :widths: 15, 10, 10, 15

   "AWS EKS with kubernetes 1.8", kubeflow 1.2, KFserving v0.4.1, `Demo link 1 <http://549e5b50-istiosystem-istio-2af2-834352904.us-west-1.elb.amazonaws.com/dex/auth/local?req=itknagh4dq35xqbe5egxbsmid>`_ 
   "OpenShift with kubernetes 1.8", kubeflow 1.4, KFserving v0.6.0, `Demo Link 2 <https://console-openshift-console.apps.ocp4-cluster-001.liuqi.io/k8s/cluster/projects>`_
   "vSphere TKG with kubernetes 1.8", kubeflow 1.4, KFserving v0.6.0, `Demo Link 3 <http://127.0.0.1:8080/?ns=kubeflow-user-example-com>`_

3.2.2 Setup and Applications on OpenShift
+++++++++++++++++++++++++++++++++++++++++
[To do]


3.2.3 Setup and Applications on vSphere TKG
+++++++++++++++++++++++++++++++++++++++++++

Login vSphere TKG
^^^^^^^^^^^^^^^^^

.. code-block:: bash
    :linenos:

    # login your vSphere TKG, 密码 Admin!23
    $ kubectl vsphere login --server=10.117.233.1 --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify --tanzu-kubernetes-cluster-namespace=liuqi --tanzu-kubernetes-cluster-name=tkgs-cluster-31

    # export your vSphere TKG port, and login kubeflow ui with username (user@example.com) and password (12341234)
    $ kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80


Applications on vSphere TKG
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Single Model InferenceService:

.. code-block:: console
    :linenos:

    # Deploy a model inferenceservice [demo: sklearn-iris <sert a link>]
    kubectl apply -f sklearn.yaml
    Output
    $ inferenceservice.serving.kserve.io/sklearn-iris created

    # Run a prediction with curl
    MODEL_NAME=sklearn-iris
    INPUT_PATH=@./iris-input.json
    SESSION=[login your kubeflow ui find the request header' Cookie <https://developer.chrome.com/docs/devtools/storage/cookies/>]
    SERVICE_HOSTNAME=$(kubectl get -n kfserving-samples inferenceservice ${MODEL_NAME} -o jsonpath='{.status.url}' | cut -d "/" -f 3)
    curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Cookie: authservice_session=${SESSION}" http://127.0.0.1:8080/v1/models/${MODEL_NAME}:predict -d ${INPUT_PATH}


.. csv-table:: Table 2: Out-of-the-box Predictor
   :header: "Model Name", "Verification", "Description"
   :widths: 15, 10, 30

   "Sklearn", "Pass", "On a stick!"
   "Tensorflow", "Pass", "If we took the bones out,"
   "PyTorch", "Not Pass [insufficient CPU]", "On a stick!"
   "Paddle", "Pass", "On a stick!"
   "XGBoost", "Pass", "On a stick!"
   "LightGBM", "Pass", "On a stick!"
   "Transformer", "Not test", "On a stick!"
   "Rollout", "Pass", "On a stick!"

* Custom Model InferenceService: [To do]

.. code-block:: bash
    :linenos:

    # Build a model server with docker ➡️ Create the InferenceService with yaml file ➡️  Run a prediction ➡️ Delete the InferenceService
    kubectl apply -f sklearn.yaml
    Output
    $ inferenceservice.serving.kserve.io/sklearn-iris created


* Deploy InferenceService with Cloud/PVC storage: [To do]

* Using KServe Python SDK: [To do]


3.3 KServe Extension [advance]
------------------------------

3.3.1 Kserve Python SDK
+++++++++++++++++++++++

Overview
^^^^^^^^

Python SDK for KFServing Server and Client

.. code-block:: bash
    :linenos:

    # Installation
    pip install kfserving

    # Install via Setuptools
    sudo python setup.py install    # for all user
    or 
    python setup.py install --user

KFServing Server
^^^^^^^^^^^^^^^^^^
KFServing's python server libraries implement a standardized KFServing library that is extended by model serving frameworks such as Scikit Learn, XGBoost and 
PyTorch. It encapsulates data plane API definitions and storage retrieval for models

KFServing Client
^^^^^^^^^^^^^^^^^^

KFServing's python client interacts with KFServing control plane APIs for executing operations on a remote KFServing cluster, such as creating, 
patching and deleting of a InferenceService instance

API Groups:

* KnativeAddressable
* KnativeCondition
* KnativeURL
* V1beta1Batcher
* V1beta1ComponentExtensionSpec
* V1beta1CustomExplainer
* V1beta1InferenceService
* V1beta1InferenceServiceList
* and etc...
