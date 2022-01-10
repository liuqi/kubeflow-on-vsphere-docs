Operation
=========

ML Model Monitoring
-------------------

Why monitoring the models in production
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A model may go out of context if there is data skew i.e. data distribution may have changed in production from what was used during training. It may also be that a feature becomes unavailable in production data or that the model may no longer be relevant as the real-world environment might have changed (e.g. Covid19) or further and more simply, the user behavior may have changed. Monitoring the changes in the model’s behavior and the characteristics of the most recent data used at inference is thus of utmost importance. This ensures that the model remains relevant and/or true to the desired performance as promised during the model training phase.

The primary motivation of model monitoring is to an important feedback loop post-deployment back to the model building phase. This helps the ML model to constantly improve itself by deciding to either update the model or continue with the existing model. To enable this decision the model monitoring framework should track & report several important metrics.

Model monitoring within the realm of MLOps has become a necessity for mature ML systems. It is quintessential to implement such a framework to ensure consistency and robustness of the ML system, as without it ML systems may lose the “trust” of the end-user, which could be fatal. As such including and planning for it in the overall solution architecture of any ML use case implementation is of utmost importance.

What to monitor
^^^^^^^^^^^^^^^

1. Stability Metrics: 

- Prior Probability Shift. 

Captures the Prior Probability Shift i.e. distribution shift of the predicted outputs and/or dependent variable between either the training data and production data (scenario I) or various time frames of the production data (scenario II). Examples of these metrics include Population Stability Index (PSI) & Divergence Index.

- Covariate Shift. 

Captures the Covariate Shift i.e. distribution shift of each independent variable between either the training data and production data (scenario I) or various time frames of the production data (scenario II), as applicable. Examples of these metrics include Characteristic Stability Index (CSI) & Novelty Index.

#. Performance Metrics: 

- Project Metrics like RMSE, R-Square, etc for regression and accuracy, AUC-ROC, etc for classification.
- Gini and KS -Statistics: A statistical measure of how well the predicted probabilities/classes are separated (only for classification models)

#. Operations Metrics.

Examples include,
- Throughput for calling ML API endpoints (no. of requests)
- Latency when calling ML API endpoints (avg. response time)
- IO/Memory/CPU usage when performing prediction (avg. consumption)
- Disk utilization (avg. consumption)
- System uptime

How to monitor
^^^^^^^^^^^^^^

SageMaker's implementation

**Monitor Data Quality**

ML models in production have to make predictions on real-life data that is not carefully curated like most training datasets. If the statistical nature of the data that your model receives while in production drifts away from the nature of the baseline data it was trained on, the model begins to lose accuracy in its predictions. Amazon SageMaker Model Monitor uses rules to detect data drift and alerts you when it happens. To monitor data quality, follow these steps:

* Enable data capture. This captures inference input and output from a real-time inference endpoint and stores the data in Amazon S3. For more information, see Capture Data.

* Create a baseline. In this step, you run a baseline job that analyzes an input dataset that you provide. The baseline computes baseline schema constraints and statistics for each feature using Deequ, an open source library built on Apache Spark, which is used to measure data quality in large datasets. For more information, see Create a Baseline.

* Define and schedule data quality monitoring jobs. For more information, see Schedule Monitoring Jobs.

* View data quality metrics. For more information, see Schema for Statistics (statistics.json file).

* Integrate data quality monitoring with Amazon CloudWatch. For more information, see CloudWatch Metrics.

* Interpret the results of a monitoring job. For more information, see Interpret Results.

* Use SageMaker Studio to enable data quality monitoring and visualize results. For more information, see Visualize Results in Amazon SageMaker Studio.

**Monitor Model Quality**

Model quality monitoring jobs monitor the performance of a model by comparing the predictions that the model makes with the actual ground truth labels that the model attempts to predict. To do this, model quality monitoring merges data that is captured from real-time inference with actual labels that you store in an Amazon S3 bucket, and then compares the predictions with the actual labels.

To measure model quality, model monitor uses metrics that depend on the ML problem type. For example, if your model is for a regression problem, one of the metrics evaluated is mean square error (mse). For information about all of the metrics used for the different ML problem types, see Model Quality Metrics.

Model quality monitoring follows the same steps as data quality monitoring, but adds the additional step of merging the actual labels from Amazon S3 with the predictions captured from the real-time inference endpoint. To monitor model quality, follow these steps

**Monitor Bias Drift for models in Production**

Amazon SageMaker Clarify bias monitoring helps data scientists and ML engineers monitor predictions for bias on a regular basis. As the model is monitored, customers can view exportable reports and graphs detailing bias in SageMaker Studio and configure alerts in Amazon CloudWatch to receive notifications if bias beyond a certain threshold is detected. Bias can be introduced or exacerbated in deployed ML models when the training data differs from the data that the model sees during deployment (that is, the live data). These kinds of changes in the live data distribution might be temporary (for example, due to some short-lived, real-world events) or permanent. In either case, it might be important to detect these changes. For example, the outputs of a model for predicting home prices can become biased if the mortgage rates used to train the model differ from current, real-world mortgage rates. With bias detection capabilities in Model Monitor, when SageMaker detects bias beyond a certain threshold, it automatically generates metrics that you can view in SageMaker Studio and through Amazon CloudWatch alerts.

In general, measuring bias only during the train-and-deploy phase might not be sufficient. It is possible that after the model has been deployed, the distribution of the data that the deployed model sees (that is, the live data) is different from data distribution in the training dataset. This change might introduce bias in a model over time. The change in the live data distribution might be temporary (for example, due to some short-lived behavior like the holiday season) or permanent. In either case, it might be important to detect these changes and take steps to reduce the bias when appropriate.

To detect these changes, SageMaker Clarify provides functionality to monitor the bias metrics of a deployed model continuously and raise automated alerts if the metrics exceed a threshold. For example, consider the DPPL bias metric. Specify an allowed range of values A=(amin​,amax​), for instance an interval of (-0.1, 0.1), that DPPL should belong to during deployment. Any deviation from this range should raise a bias detected alert. With SageMaker Clarify, you can perform these checks at regular intervals.

**Monitor Feature Attribution Drift for Models in Production**

A drift in the distribution of live data for models in production can result in a corresponding drift in the feature attribution values, just as it could cause a drift in bias when monitoring bias metrics. Amazon SageMaker Clarify feature attribution monitoring helps data scientists and ML engineers monitor predictions for feature attribution drift on a regular basis. As the model is monitored, customers can view exportable reports and graphs detailing feature attributions in SageMaker Studio and configure alerts in Amazon CloudWatch to receive notifications if it is detected that the attribution values drift beyond a certain threshold. 

General ML Application monitoring
---------------------------------

Promethius for metrics monitoring
Grafana for data visualization
Jaeger for distributed system tracing
??? for log analysis


GPU Resource Utilization Monitoring
-----------------------------------

NVIDIA Data Center GPU Manager (DCGM) is a suite of tools for managing and monitoring NVIDIA datacenter GPUs in cluster environments. It includes active health monitoring, comprehensive diagnostics, system alerts and governance policies including power and clock management. It can be used standalone by infrastructure teams and easily integrates into cluster management tools, resource scheduling and monitoring products from NVIDIA partners.

DCGM simplifies GPU administration in the data center, improves resource reliability and uptime, automates administrative tasks, and helps drive overall infrastructure efficiency. DCGM supports Linux operating systems on x86_64, Arm and POWER (ppc64le) platforms. The installer packages include libraries, binaries, NVIDIA Validation Suite (NVVS) and source examples for using the API (C, Python and Go).

DCGM integrates into the Kubernetes ecosystem by allowing users to gather GPU telemetry using dcgm-exporter.

https://github.com/NVIDIA/DCGM