
import profile_get
import pandas as pd

df = pd.read_csv("surf_boards_w_length.csv")
df = df[df['Volume'] != 'NO BOARD LITERS']

df.loc[df['Volume'].str.contains('L', na=False), 'Volume'] = 0

# Convert remaining rows to integers
df['Volume'] = df['Volume'].astype(float)


def get_volume_quality(quality_score):
    # Basic Implementation of how to convert the quality score from the model to the volume equation
    if quality_score < 1.5:
        return 1
    
    elif quality_score < 2.5:
        return 2
    
    else:
        return 3


def calculate_volume(wave_size_meters, quality):
    """
    Calculate surfboard volume based on wave size (meters) and wave quality.
    Smaller waves and worse quality result in higher volume recommendations.

    Parameters:
    wave_size_meters (float): Wave size in meters (e.g., 0.6 for small waves).
    wave_quality (int): Wave quality rating (1=Poor, 2=Average, 3=Good, 4=Excellent).

    Returns:
    float: Recommended surfboard volume.
    """
    profile = profile_get.get_profile()
    wave_quality = get_volume_quality(quality)

    # Hardcoded surfer attributes
    weight = profile['Weight']
    age = profile['Age']
    height = profile['Height']
    gender = profile['Gender']

    fitness = profile['Fitness']  # Reasonably fit
    level = profile['Level (Value)']  # Competent surfer
    level_score = profile['Level']

    # Calculate weight factor
    if 40 <= weight <= 83:
        weight_val = weight * 0.3333
    else:
        weight_val = weight * 0.3333 + 0.5

    # Hardcoded age factor (based on age=22)
    age_factor = 0  # 22 years falls under the default range with no adjustment

    # Introduce coefficients for wave size and wave quality
    wave_size_coef = 1.35  # Amplifies the impact of wave size
    wave_quality_coef = 1.25  # Amplifies the impact of wave quality

    # Adjust wave size impact (smaller waves increase volume)
    wave_size_factor = (2.0 - wave_size_meters) * wave_size_coef

    # Adjust wave quality impact (worse quality increases volume)
    wave_quality_factor = (5 - wave_quality) * wave_quality_coef

    # Calculate surfboard volume
    volume = weight_val + age_factor + gender + fitness + level + wave_size_factor + wave_quality_factor
    volume_raw = round(volume, 1)
    volume_int = int(volume_raw)

    return {
        'Volume' : volume_int,
        'Quality' : wave_quality
    }

def locate_boards(board_stats):
    # volume_int, quality
    volume_int = board_stats['Volume']
    quality = board_stats['Quality']
    
    height_difference = {
    'Small Wave ShortBoard / Grovler' : {'B': 0, 'I' : -3, 'E' : -6},
    'Performance ShortBoard' : {'B': 4, 'I' : 1, 'E' : 0},
    'Step-Up/Gun' : {'B': 10, 'I' : 7, 'E' : 5}
    }
    profile = profile_get.get_profile()
    cm_height = profile['Height']
    level = profile['Level']
    height = int(cm_height / 2.54)
    min_volume, max_volume = (volume_int-3), (volume_int+3)

    if (quality == 1):
        board_type = 'Small Wave ShortBoard / Grovler'
        board_diff = height_difference['Small Wave ShortBoard / Grovler'][level]
    elif (quality == 2):
        board_type = 'Performance ShortBoard'
        board_diff = height_difference['Performance ShortBoard'][level]
    else:
        board_type = 'Step-Up/Gun'
        board_diff = height_difference['Step-Up/Gun'][level]

    board_length = height - board_diff
    min_length, max_length = int(board_length-3), int(board_diff+3)
    print(min_length)
    print(min_volume)
    filtered_boards = df[
        (df['Volume'].astype(float) >= min_volume) &
        (df['Volume'].astype(float) <= max_volume)
        # (df['Total Length (inches)'] >= min_length) &
        # (df['Total Length (inches)'] <= max_length)
    ]
    shuffled_boards = filtered_boards.sample(n=5, random_state=42)

    return_dict = {
        'Board Type' : board_type,
        'Boards' : shuffled_boards
    }
    return return_dict

'''
# Example usage
wave_size_meters = 0.5  # Wave size in meters (e.g., 0.5m ~ 1.6ft waves)
wave_quality = 1  # Wave quality (1=Poor, 2=Average, 3=Good, 4=Excellent)

surfboard_volume = calculate_volume(wave_size_meters, wave_quality)

'''

def board_selector(wave_height, score):
    volume_metrics = calculate_volume(wave_height, score)
    selected_boards = locate_boards(volume_metrics)
    return selected_boards