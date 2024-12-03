import requests
import pandas as pd
from geopy.distance import geodesic


# Load the CSV into a DataFrame
spots_file = "spots.csv"  # Replace with the correct file path
spots_df = pd.read_csv(spots_file)

def get_coordinates():
    """
    Retrieve the user's coordinates using IP-based geolocation.
    Returns (latitude, longitude) or (None, None) if an error occurs.
    """
    try:
        response = requests.get("https://ipinfo.io")
        data = response.json()
        location = data.get("loc", "")  # Format: "latitude,longitude"
        if location:
            latitude, longitude = map(float, location.split(","))
            return latitude, longitude
        else:
            return None, None
    except Exception as e:
        print(f"Error retrieving coordinates: {e}")
        return None, None
    
def is_spot_in_dataframe(spot_name, df):
    """
    Checks if a given spot name exists in the DataFrame, case-insensitively.

    Args:
        spot_name (str): The spot name to search for.
        df (pd.DataFrame): The DataFrame containing the surf spots.

    Returns:
        bool: True if the spot exists, False otherwise.
    """
    # Convert input spot name to lowercase
    spot_name_lower = spot_name.lower()

    # Check if the spot name exists in the DataFrame (case-insensitively)
    return any(df["spot_name"].str.lower() == spot_name_lower)

def find_closest_spots(lat, lng, top_n=5):
    """
    Find the closest surf spots based on user's coordinates.
    
    Args:
        lat (float): User's latitude.
        lng (float): User's longitude.
        top_n (int): Number of closest spots to return (default is 5).

    Returns:
        dict: A dictionary with `spot_name` as keys and `spot_type` as values.
    """
    if lat is None or lng is None:
        print("Invalid user coordinates.")
        return {}
    
    # Calculate the distance to each spot
    distances = []
    for _, row in spots_df.iterrows():
        spot_coords = (row["lat"], row["lng"])
        user_coords = (lat, lng)
        distance = geodesic(user_coords, spot_coords).kilometers
        distances.append((row["spot_name"], row["spot_type"], distance))

    # Sort by distance
    distances.sort(key=lambda x: x[2])

    # Get the top N closest spots
    closest_spots = {name: spot_type for name, spot_type, _ in distances[:top_n]}
    return closest_spots

# Example Usage

'''
if __name__ == "__main__":
    # Get the user's coordinates
    user_lat, user_lng = get_coordinates()
    print(f"Your Coordinates: Latitude = {user_lat}, Longitude = {user_lng}")

    # Find the 5 closest spots
    closest_spots = find_closest_spots(user_lat, user_lng, top_n=5)
    print("Closest Surf Spots:")
    for spot, spot_type in closest_spots.items():
        print(f"- {spot} ({spot_type})")

'''
