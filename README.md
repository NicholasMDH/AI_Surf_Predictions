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

# How to RUN

1. Flutter have to be installed [Flutter](https://docs.flutter.dev/get-started/install)
2. Run `python enhanced_api.py` in 450chat dir.
3. Run `flutter pub get` in surfer_chatbot dir.
4. Run `flutter run -d web-server` in surfer*chatbot dir. it will give you a link (i.e: http://localhost:<port*#>) that launches the web app in a browser.
