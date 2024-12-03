import pandas as pd
import pickle
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split

# Load the dataset
file_path = 'waves_statsV2.csv'
data = pd.read_csv(file_path)

# Define secondary swell columns to check
# Seeing if any of these == Nothing, in that case i set to NaN
secondary_swell_cols = [
    "Seconday 1 -> height", "Seconday 1 -> period", "Seconday 1 -> letters", "Seconday 1 -> angle", "Secondary 1 -> Points off",
    "Seconday 2 -> height", "Seconday 2 -> period", "Seconday 2 -> letters", "Seconday 2 -> angle", "Secondary 2 -> Points off",
    "Seconday 3 -> height", "Seconday 3 -> period", "Seconday 3 -> letters", "Seconday 3 -> angle", "Secondary 3 -> Points off",
    "Primary -> Points off",
    "Wind -> Points off"
]

# Iterate through rows and check for missing values of the rows in the list up there
for index, row in data.iterrows():
    for col in secondary_swell_cols:
        if pd.isna(row[col]) or row[col] == '':
            data.at[index, col] = None  # Replace missing or empty values with None

# List of columns to drop
columns_to_drop = [
    "DocumentID", "DatesDocumentID", "timestamp", "name", "County", "Name", "data",
    "Surf Height: Direction",
    "Seconday 1 -> letters",
    "Primary -> letters",
    "Seconday 2 -> letters",
    "Seconday 3 -> letters",
    "Wind Direction (NSEW)"
]

# Drop the columns from the DataFrame
data_swell = data.drop(columns=columns_to_drop)

# Shuffling all lines, forecasts are cumulative which means it would be biased if we split the data without shuffling
data_swell = data_swell.sample(frac=1, random_state=42).reset_index(drop=True)

# Convert categorical column to one-hot encoding
data_swell_encoded = pd.get_dummies(data_swell, columns=["Wind Direction (Human Relation)"], drop_first=True)

# Features and target
features = data_swell_encoded.drop(columns=['Star Rating'])
target = data_swell_encoded['Star Rating']

# Split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)

# Initialize and train the model
model = RandomForestRegressor(random_state=42)
model.fit(X_train, y_train)

# Save the trained model to a .pkl file
model_file_path = 'random_forest_model.pkl'
with open(model_file_path, 'wb') as model_file:
    pickle.dump(model, model_file)

print(f"Model saved to {model_file_path}")

# Predict on the test set
predictions = model.predict(X_test)

# Evaluate the model
default_mae = mean_absolute_error(y_test, predictions)
default_r2 = r2_score(y_test, predictions)

# Output evaluation metrics
print(f"Mean Absolute Error (MAE): {default_mae}")
print(f"R-squared Score: {default_r2}")

# Feature importance (optional)
feature_importances = pd.DataFrame({
    'Feature': X_train.columns,
    'Importance': model.feature_importances_
}).sort_values(by='Importance', ascending=False)

print("10 most important features:")
print(feature_importances.head(10))