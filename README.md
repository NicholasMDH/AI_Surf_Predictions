# Project Description:
- This repository is using historical surf data stored in a firebase database to train an AI model to predict the quality of surf on a given day.

# Model Description:
- The main model is contained in the modelV0.ipynb file
- This model is written in python 3, and has the following dependencies:
    - pandas
    - scikit-learn
    - matplotlib
- This model uses a Random Forest Regressor, and sklearn's GridSearchCV to tune the hyperparameters of the Random Forest Regressor
- This code also compares the results of the model before and after tuning the hyperparameters to show the difference
