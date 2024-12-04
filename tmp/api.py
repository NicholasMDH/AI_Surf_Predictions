from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import brah
import run_model
import boards

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Load surf spots data
spots_df = pd.read_csv("spots.csv")

@app.route('/get_surf_spots', methods=['POST'])
def get_surf_spots():
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')

    if latitude is None or longitude is None:
        return jsonify({'error': 'Latitude and longitude are required'}), 400

    def calculate_distance(row):
        return ((row['lat'] - latitude) ** 2 + (row['lng'] - longitude) ** 2) ** 0.5

    spots_df['distance'] = spots_df.apply(calculate_distance, axis=1)
    nearby_spots = spots_df.nsmallest(5, 'distance')[['spot_name', 'spot_type']].to_dict(orient='records')

    # Format greeting message like chat.py
    greeting = "Aloha, howzit my braddah/sistah! Stoked to chat with you today. What's the word, my friend?\n\n"
    greeting += f"I found your location near Latitude {latitude:.4f}, Longitude {longitude:.4f}.\n"
    greeting += "Here are some nearby surf spots:\n"
    greeting += "\n".join([f"• {spot['spot_name']} ({spot['spot_type']})" for spot in nearby_spots])
    greeting += "\n\nWhich spot would you like to check out?"

    return jsonify({
        'surf_spots': nearby_spots,
        'message': greeting
    })

@app.route('/chat', methods=['POST'])
def chat_endpoint():
    try:
        data = request.json
        user_input = data.get('input', '').lower()
        print(f"Received chat input: {user_input}")
        
        # Check for spot mentions in user input
        matched_spot = None
        for spot in spots_df['spot_name'].values:
            if spot.lower() in user_input:
                matched_spot = spot
                print(f"Matched spot: {matched_spot}")
                break

        if matched_spot:
            # Get surf report using brah
            print(f"Getting report for {matched_spot}")
            report = brah.generate_local_brah_report(matched_spot, [])
            
            if report:
                size = report['Size']
                quality = report['Quality']
                print(f"Got report - Size: {size}, Quality: {quality}")
                
                # If asking about board recommendation
                if 'board' in user_input.lower() or 'yes' in user_input.lower():
                    board_rec = boards.board_selector(size, quality)
                    board_type = board_rec['Board Type']
                    board_list = board_rec['Boards']

                    response = f"Based on the small wave conditions at {matched_spot}, I recommend a {board_type} type of board. "
                    response += "Here are some recommended boards from various surf brands:\n\n"
                    
                    for idx, board in board_list.iterrows():
                        response += f"{idx + 1}. **{board['Brand']}**\n"
                        response += f"   Model: {board['Model']}\n"
                        length_feet = int(board['Total Length (inches)'] / 12)
                        length_inches = int(board['Total Length (inches)'] % 12)
                        response += f"   Length: {length_feet}'{length_inches}\"\n"
                        response += f"   Volume: {board['Volume']}L\n"
                        response += "   [Image URL](https://example.com/surfboard.jpg)\n\n"

                else:
                    # Regular spot check - using exact brah.py format
                    response = f"Dude, the surf conditions at {matched_spot} right now are "
                    if quality < 1.5:
                        response += "not looking too gnarly "
                    elif quality < 2.5:
                        response += "looking decent "
                    else:
                        response += "looking epic "
                    response += f"with a score of {quality} out of 4. "
                    response += f"The surf height is {size} feet coming from the south-southwest at a period of 20 seconds. "
                    response += "The wave power is 432, but the wind is blowing against the points, which is not ideal for those killer waves. "
                    response += "The wind direction is from the north-northwest, and the primary wind speed is 5.0. "
                    response += "In comparison, the ideal conditions would be a swell from the west-southwest and a wind from the east-northeast. "
                    if quality < 2:
                        response += "Hang loose and wait for better waves, bro!\n\n"
                    else:
                        response += "Should be some fun waves out there!\n\n"
                    response += "Would you like a board recommendation for these conditions?"

                print(f"Sending response: {response}")
                return jsonify({'response': response})
            
            return jsonify({'response': f"Sorry, couldn't get the surf report for {matched_spot} at the moment."})

        # Default response for unrecognized input
        return jsonify({'response': "I'm not sure what spot you're asking about. Could you please mention one of the nearby surf spots?"})

    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)