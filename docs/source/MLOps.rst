MLOps
=====
.. figure:: ./figs/MLOps-intro.png
   :width: 720
   :scale: 100%
   :align: center

   Figure 1 - The ML design life cycle.

Data
-----
* Ingestion

Process the data into a format that the following components can digest.

* Validation
  
Check that the statistics of the ingested data are as expected 
(e.g., the range, number of categories, and distribution of categories)

* Preprocessing

Preprocess the data to use it for the training runs. Perform any feature engineering.

Model
-----
* Training

Train a model to take inputs and predict an output with the lowest error possible.

* Test/Evaluate

Evaluate the trained model performance on a separate set of data points (test dateaset)
by various metrics: accuracy, precision, recall, and f-score.

* Tuning

Determine the optimal hyperparameters of a machine learning model.
Model parameters and hyperparameter values are tuned to generate the most accurate and reliable model. 
Model parameters are learned attributes that define individ‐ ual models derived directly from the training data 
(e.g., regression coefficients and decision tree split locations). 
Hyperparameters express higher-level structural settings for algorithms, for example, the strength of the penalty used in 
regularized regres‐ sion, or the number of trees to include in a random forest. 
They are tuned to best fit the model because they can’t be learned from the data.

Deploy
------
* Deployment
* Inference

Operation
---------
* Monitor
* Analyze
* Govern