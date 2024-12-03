import pandas as pd
import pickle
import numpy as np

# Load the trained model

#openai.api_key = "KEY"

def produce_prediction(input_data):

    with open('random_forest_model.pkl', 'rb') as file:
        loaded_model = pickle.load(file)

    '''

    # Raw input data (as dictionary, matching your provided row)
    input_data = {
        "Surf Height: Size": [0.8],
        "Surf Height: Period": [20.0],
        "Surf Height: Angle": [23.0],
        "Wave Power": [432],
        "Primary -> height": [0.8],
        "Primary -> period": [20],
        "Primary -> angle": [23.0],
        "Seconday 1 -> height": [0.4],
        "Seconday 1 -> period": [7.0],
        "Seconday 1 -> angle": [90.0],
        "Seconday 2 -> height": [0.4],
        "Seconday 2 -> period": [12.0],
        "Seconday 2 -> angle": [34.0],
        "Wind Direction (Angle)": [158.0],
        "Primary Wind Speed": [5.0],
        "Wind -> Points off": [3.0],
        # Include any other features used in training
    }
    '''

    # Convert to DataFrame
    # Ensure input_data values are wrapped in lists for DataFrame compatibility
    input_data_df = pd.DataFrame({key: [value] for key, value in input_data.items()})


    # Apply one-hot encoding for categorical columns if applicable
    input_data_df['Wind Direction (Human Relation)'] = ['cross-off']
    input_data_encoded = pd.get_dummies(input_data_df, columns=["Wind Direction (Human Relation)"], drop_first=True)

    # Ensure all columns match the training feature set
    missing_cols = set(loaded_model.feature_names_in_) - set(input_data_encoded.columns)
    for col in missing_cols:
        input_data_encoded[col] = 0  # Add missing columns with default value (e.g., 0)

    # Reorder columns to match training set
    input_data_encoded = input_data_encoded[loaded_model.feature_names_in_]

    # Make predictions
    predictions = loaded_model.predict(input_data_encoded)

    # Get feature importances
    feature_importances = loaded_model.feature_importances_
    feature_names = input_data_encoded.columns

    # Pair features with their importance and sort them
    importance_df = pd.DataFrame({
        'Feature': feature_names,
        'Importance': feature_importances
    }).sort_values(by='Importance', ascending=False)

    # Get the top 5 features
    top_features = importance_df.head(5)

    # Check if swell angle and height are included in the top 5
    # Filter only swell-related angle features (e.g., Primary -> angle, Secondary 1 -> angle)
    swell_angle_features = [
        col for col in feature_names
        if 'angle' in col.lower() and any(keyword in col for keyword in ['Primary', 'Secondary', 'Swell'])
    ]

    swell_height_features = [col for col in feature_names if 'height' in col.lower()]

    # Ensure at least one swell angle and one swell height feature are included
    additional_features = []

    # Add the most important swell angle if not already included
    if not any(feature in top_features['Feature'].values for feature in swell_angle_features):
        most_important_angle = importance_df[importance_df['Feature'].isin(swell_angle_features)].iloc[0]
        additional_features.append(most_important_angle)

    # Add the most important swell height if not already included
    if not any(feature in top_features['Feature'].values for feature in swell_height_features):
        most_important_height = importance_df[importance_df['Feature'].isin(swell_height_features)].iloc[0]
        additional_features.append(most_important_height)

    # Combine top features with additional features if needed
    final_features = pd.concat([top_features, pd.DataFrame(additional_features)]).drop_duplicates().head(7)

    # Display prediction and relevant features
    print(f"Predicted Surf Quality: {predictions[0]}")
    print("\nRelevant Features Contributing to Prediction:")
    print(final_features)

    return_dict = {

        'Quality Score' : predictions[0],
        'Features' : final_features

    }

    return return_dict