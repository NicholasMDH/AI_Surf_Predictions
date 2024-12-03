from flask import Flask, request, jsonify
import os
import chat
import brah

# Load environment variables from .env file
openai_api_key = "KEY"

if not openai_api_key:
    raise ValueError("OpenAI API key not set. Please add it to your .env file.")

# Set up OpenAI API key in chat module
chat.openai_api_key = openai_api_key

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the Surf AI Flask App!"

@app.route('/chat', methods=['POST'])
def chat_route():
    """Chat with the surf bot."""
    try:
        data = request.json
        user_input = data.get('input', '')
        if not user_input:
            return jsonify({'error': 'No input provided'}), 400
        
        # Call the chat_with_openai function from chat.py
        response = chat.chat_with_openai([
            {"role": "user", "content": user_input}
        ])
        return jsonify({'response': response})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_report', methods=['POST'])
def generate_report():
    """Generate a local brah surf report."""
    try:
        data = request.json
        spot_name = data.get('spot_name', '')
        if not spot_name:
            return jsonify({'error': 'Spot name is required'}), 400

        # Call the generate_local_brah_report function from brah.py
        report = brah.generate_local_brah_report(spot_name, [])
        return jsonify({'report': report})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)