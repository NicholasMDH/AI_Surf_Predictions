import pandas as pd
import openai
import chat
import run_model

# Load the simulated live surf data
simulated_live_file = "simulated_live_surf.csv"  # Replace with the actual path to your CSV file
simulated_live_df = pd.read_csv(simulated_live_file)

csv_file = "spotsV22.csv"  # Replace with the correct path to your CSV file
spots_df = pd.read_csv(csv_file)

def generate_local_brah_report(spot_name, messages):
    """
    Generates a 'local brah' style report for the selected spot using OpenAI's API.

    Args:
        spot_name (str): The name of the surf spot.
        messages (list): The conversation history.

    Returns:
        str: The API-generated report text.
    """
    # Filter data for the selected spot
    print(spot_name)
    spot_data = simulated_live_df[simulated_live_df["DocumentID"] == spot_name]
    
    if spot_data.empty:
        messages.append({"role": "assistant", "content": f"Sorry, brah! No conditions found for {spot_name}."})
        return "Sorry, brah! I couldn't find any conditions for this spot."

    # Randomly select one row for the spot
    spot_conditions = spot_data.sample(n=1, random_state=None).iloc[0]
    
    # Prepare a report without model prediction
    conditions_text = (
        f"Swell size: {spot_conditions['Surf Height: Size']} meters\n"
        f"Swell period: {spot_conditions['Surf Height: Period']} seconds\n"
        f"Wind speed: {spot_conditions['Primary Wind Speed']} km/h\n"
    )


    # Create a temporary context for generating the report
    dynamic_context = [
        {"role": "system", "content": "You are a surf bot. Generate a surfer-style summary based on these conditions."},
        {"role": "user", "content": f"Here are the conditions for {spot_name}:\n{conditions_text}"},
    ]

    # Generate a dynamic "local brah" response from OpenAI
    report = chat.chat_with_openai(dynamic_context)
    quality_input = extract_features(spot_conditions)
    quality = run_model.produce_prediction(quality_input)

    ideal = get_ideal_conditions(spot_name)

    analysis = analyze_quality(spot_name, quality, ideal, spot_conditions)

    # print(report)
    # print()
    messages.append({"role": "assistant", "content": report})

    print(analysis)
    print()
    messages.append({"role": "assistant", "content": analysis})
    return {
        'Size' : spot_conditions['Surf Height: Size'],
        'Quality' : quality['Quality Score']
    }

def analyze_quality(spot_name, quality_dict, ideal, conditions):
    score = quality_dict['Quality Score']
    features = quality_dict['Features']

    dynamic_context = [
        {"role": "system", "content": f"You are a surf bot. Generate a surfer-style summary based on this score {score} out of 4 and most relevant conditions, live conditons, and comapre them to the spots ideal conditions if applicable."},
        {"role": "user", "content": f"Here are the relevant conditions for {spot_name} and its score {score}:\n{features}"},
        {"role": "user", "content": f"Here are the LIVE conditions for {spot_name}:\n{conditions}"},
        {"role": "user", "content": f"Here are the IDEAL conditions for {spot_name}:\n{ideal}"},
    ]

    analysis = chat.chat_with_openai(dynamic_context)

    return analysis


def extract_features(conditions):

    '''
    Function to extract the nesseasry conditons for the model to perform
    the prediciton.
    '''

    model_input = {
        "Surf Height: Size": conditions["Surf Height: Size"],
        "Surf Height: Period": conditions["Surf Height: Period"],
        "Surf Height: Angle": conditions["Surf Height: Angle"],
        "Wave Power": conditions["Wave Power"],
        "Primary -> height": conditions["Primary -> height"],
        "Primary -> period": conditions["Primary -> period"],
        "Primary -> angle": conditions["Primary -> angle"],
        "Primary -> Points off": conditions["Primary -> Points off"],
        "Seconday 1 -> height": conditions["Seconday 1 -> height"],
        "Seconday 1 -> period": conditions["Seconday 1 -> period"],
        "Seconday 1 -> angle": conditions["Seconday 1 -> angle"],
        "Secondary 1 -> Points off": conditions["Secondary 1 -> Points off"],
        "Seconday 2 -> height": conditions["Seconday 2 -> height"],
        "Seconday 2 -> period": conditions["Seconday 2 -> period"],
        "Seconday 2 -> angle": conditions["Seconday 2 -> angle"],
        "Secondary 2 -> Points off": conditions["Secondary 2 -> Points off"],
        "Seconday 3 -> height": conditions["Seconday 3 -> height"],
        "Seconday 3 -> period": conditions["Seconday 3 -> period"],
        "Seconday 3 -> angle": conditions["Seconday 3 -> angle"],
        "Secondary 3 -> Points off": conditions["Secondary 3 -> Points off"],
        "Wind Direction (Angle)": conditions["Wind Direction (Angle)"],
        "Primary Wind Speed": conditions["Primary Wind Speed"],
        "Wind -> Points off": conditions["Wind -> Points off"],
        # Include any other features used in training
    }

    return model_input

def get_ideal_conditions(spot_name):
    """
    Retrieves the ideal conditions for a given surf spot.

    Args:
        spot_name (str): The name of the surf spot.

    Returns:
        dict: A dictionary containing the ideal conditions for the spot, or None if not found.
    """
    # Filter the DataFrame for the matching spot_name
    spot_conditions = spots_df[spots_df['spot_name'].str.lower() == spot_name.lower()]
    
    # Check if the spot is found
    if spot_conditions.empty:
        return None

    # Extract ideal conditions for the spot
    spot_conditions = spot_conditions.iloc[0]
    ideal_conditions = {
        "Ideal Swell Direction": spot_conditions["Ideal Swell Dir"],
        "Ideal Wind Direction": spot_conditions["Ideal Wind Dir"],
        "Ideal Swell Angle": spot_conditions["Ideal Swell Angle"],
        "Ideal Wind Angle": spot_conditions["Ideal Wind Angle"],
    }

    return ideal_conditions