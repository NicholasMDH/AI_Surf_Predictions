from flask import Flask, request, jsonify, make_response
from flask_cors import CORS
import pandas as pd
import numpy as np
from enhanced_model import EnhancedSurfModel
import json
from datetime import datetime, timedelta
import brah
import boards
import random

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Load the enhanced model
model = EnhancedSurfModel.load('enhanced_surf_model.pkl')

# Load surf spots data
spots_df = pd.read_csv("spots.csv")

@app.route('/get_surf_spots', methods=['POST', 'OPTIONS'])
def get_surf_spots():
    if request.method == 'OPTIONS':
        return _build_cors_preflight_response()
        
    data = request.json
    latitude = data.get('latitude')
    longitude = data.get('longitude')

    if latitude is None or longitude is None:
        return jsonify({'error': 'Latitude and longitude are required'}), 400

    def calculate_distance(row):
        return ((row['lat'] - latitude) ** 2 + (row['lng'] - longitude) ** 2) ** 0.5

    spots_df['distance'] = spots_df.apply(calculate_distance, axis=1)
    nearby_spots = spots_df.nsmallest(5, 'distance')[['spot_name', 'spot_type']].to_dict(orient='records')

    # Format greeting message
    greeting = "Aloha, howzit my braddah/sistah! Stoked to chat with you today. What's the word, my friend?\n\n"
    greeting += f"I found your location near Latitude {latitude:.4f}, Longitude {longitude:.4f}.\n"
    greeting += "Here are some nearby surf spots:\n"
    greeting += "\n".join([f"• {spot['spot_name']} ({spot['spot_type']})" for spot in nearby_spots])
    greeting += "\n\nWhich spot would you like to check out?"

    return jsonify({
        'surf_spots': nearby_spots,
        'message': greeting
    })

@app.route('/chat', methods=['POST', 'OPTIONS'])
def chat_endpoint():
    if request.method == 'OPTIONS':
        return _build_cors_preflight_response()
        
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

                    response = f"Based on the wave conditions at {matched_spot}, I recommend a {board_type} type of board. "
                    response += "Here are some recommended boards from various surf brands:\n\n"
                    
                    for idx, board in board_list.iterrows():
                        response += f"{idx + 1}. **{board['Brand']}**\n"
                        response += f"   Model: {board['Model']}\n"
                        length_feet = int(board['Total Length (inches)'] / 12)
                        length_inches = int(board['Total Length (inches)'] % 12)
                        response += f"   Length: {length_feet}'{length_inches}\"\n"
                        response += f"   Volume: {board['Volume']}L\n\n"

                else:
                    # Regular spot check
                    response = f"Dude, the surf conditions at {matched_spot} right now are "
                    if quality < 1.5:
                        response += "not looking too gnarly "
                    elif quality < 2.5:
                        response += "looking decent "
                    else:
                        response += "looking epic "
                    response += f"with a score of {quality} out of 4. "
                    response += f"The surf height is {size} feet coming from the south-southwest at a period of 20 seconds. "
                    response += "The wind direction is from the north-northwest, and the primary wind speed is 5.0. "
                    response += "Would you like a board recommendation for these conditions?"

                print(f"Sending response: {response}")
                return jsonify({'response': response})
            
            return jsonify({'response': f"Sorry, couldn't get the surf report for {matched_spot} at the moment."})

        return jsonify({'response': "I'm not sure what spot you're asking about. Could you please mention one of the nearby surf spots?"})

    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/enhanced_prediction', methods=['POST', 'OPTIONS'])
def get_enhanced_prediction():
    if request.method == 'OPTIONS':
        return _build_cors_preflight_response()
        
    try:
        data = request.json
        spot_name = data.get('spot_name')
        
        if not spot_name:
            return jsonify({'error': 'Spot name is required'}), 400
            
        # Get the surf report using brah
        report = brah.generate_local_brah_report(spot_name, [])
        
        if not report:
            return jsonify({'error': 'Could not generate report'}), 500
            
        # Extract data from report
        size = report['Size']
        quality = report['Quality']
        
        # Format the feature contributions
        feature_contributions = [
            {
                'name': 'Wave Power',
                'value': report.get('Wave Power', 0),
                'importance': 0.767161,
                'description': 'Overall wave energy'
            },
            {
                'name': 'Wind Factor',
                'value': report.get('Primary Wind Speed', 0),
                'importance': 0.083602,
                'description': 'Wind effect on waves'
            },
            {
                'name': 'Wave Height',
                'value': size,
                'importance': 0.070053,
                'description': 'Current wave height'
            }
        ]
        
        # Create 24h forecast
        forecast = []
        base_hour = datetime.now().hour
        for i in range(24):
            hour = (base_hour + i) % 24
            forecast.append({
                'hour': hour,
                'rating': quality * (1 + (random.random() - 0.5) * 0.2),  # Add some variation
                'wave_height': size * (1 + (random.random() - 0.5) * 0.1),
                'wind_speed': report.get('Primary Wind Speed', 5)
            })

        response = {
            'spot': {
                'name': spot_name,
                'lat': data.get('latitude'),
                'lng': data.get('longitude')
            },
            'current_conditions': {
                'rating': quality,
                'confidence': 0.85,
                'wave_height': size,
                'wave_direction': 'SSW',
                'wind_speed': report.get('Primary Wind Speed', 0),
                'wind_direction': 'NNW'
            },
            'feature_contributions': feature_contributions,
            'forecast': forecast,
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify(response)
        
    except Exception as e:
        print(f"Error in enhanced prediction: {e}")
        return jsonify({'error': str(e)}), 500

def _build_cors_preflight_response():
    response = make_response()
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Headers", "*")
    response.headers.add("Access-Control-Allow-Methods", "*")
    return response

if __name__ == '__main__':
    app.run(debug=True)