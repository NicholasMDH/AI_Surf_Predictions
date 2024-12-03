import pandas as pd

# Read the input CSV file
input_file = "surfboards.csv"  # Input file name
output_file = "surf_boards_w_length.csv"  # Output file name

def calculate_length_in_inches(length_str):
    """
    Converts a length string in the format 'X'Y"' or 'X’Y”' to total inches.
    Args:
        length_str (str): The length string (e.g., "6'0\"", "6'0", "6’0”").
    Returns:
        int: Total length in inches, or None if invalid.
    """
    try:
        # Clean the string: remove special quotes and extra spaces
        length_str = length_str.strip().replace('"', "").replace("”", "").replace("‘", "'").replace("’", "'")
        
        # Split into feet and inches
        feet, inches = length_str.split("'")
        total_inches = int(feet) * 12 + int(inches)
        return total_inches
    except Exception as e:
        print(f"Error processing length: {length_str}. Error: {e}")
        return None  # Return None for invalid inputs

# Load the surfboards data
surfboards_df = pd.read_csv(input_file)

# Calculate the total length in inches and add it as a new column
surfboards_df['Total Length (inches)'] = surfboards_df['Length'].apply(calculate_length_in_inches)

# Save the updated DataFrame to a new CSV file
surfboards_df.to_csv(output_file, index=False)

print(f"Processed data has been saved to '{output_file}'.")