import openai
import pandas as pd
import location
import brah
import boards
from difflib import get_close_matches

# Replace 'your-api-key' with your actual OpenAI API key
openai.api_key = 'KEY'
# Load the spots data
csv_file = "spots.csv"  # Replace with the correct path to your CSV file
spots_df = pd.read_csv(csv_file)


def chat_with_openai(messages):
    """
    Interacts with OpenAI's API using the provided conversation history.

    Args:
        messages (list): List of dictionaries representing the conversation history.

    Returns:
        str: OpenAI's response.
    """
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=200,
            temperature=0.7,
        )
        return response["choices"][0]["message"]["content"].strip()
    except Exception as e:
        return f"Error communicating with OpenAI: {e}"


def surf_bot():
    """
    Main function to run the surf bot.
    Continuously takes user input, analyzes it using OpenAI, and maintains conversation flow.
    """
    # Step 1: Get user location and closest spots
    user_lat, user_lng = location.get_coordinates()
    if user_lat is None or user_lng is None:
        print("Error: Unable to retrieve user location.")
        return

    closest_spots = location.find_closest_spots(user_lat, user_lng, top_n=5)
    closest_spot_names = [spot for spot in closest_spots.keys()]  # Normalize for easier matching
    closest_spots_text = "\n".join([f"- {spot} ({spot_type})" for spot, spot_type in closest_spots.items()])

    # Step 2: Generate a dynamic greeting
    greeting_prompt = [
        {"role": "system", "content": "You are a friendly Hawaiian surf bot who talks like a local braddah. Greet the user."}
    ]
    greeting_message = chat_with_openai(greeting_prompt)

    # Start conversation with greeting and closest spots
    messages = [
        {"role": "system", "content": "You are a helpful surf bot that assists users with surf spots and evaluates their quality."},
        {"role": "assistant", "content": f"{greeting_message}\n\nI found your location near Latitude {user_lat:.4f}, Longitude {user_lng:.4f}.\nHere are some nearby surf spots:\n{closest_spots_text}\n\nWhich spot are you planning to surf today?"},
    ]
    print(messages[-1]['content'])

    while True:
        # Step 3: Get user input
        user_input = input("You: ").strip()

        # Exit conditions
        if user_input.lower() in ["exit", "quit", "bye"]:
            exit_message = [{"role": "assistant", "content": "Goodbye! Catch some waves soon!"}]
            print(chat_with_openai(exit_message))
            break

        # Add user input to conversation history
        messages.append({"role": "user", "content": user_input})

        print(closest_spot_names)

        # Step 4: Match user input to a spot
        match_prompt = [
        {"role": "system", "content": "You are a surf bot. Match the user's input to one of the nearby spots from this list: "
                                  + str(closest_spot_names) + "."},
        {"role": "user", "content": f"The user said: '{user_input}'. Respond with only the exact spot name from the list, as one word."}
        ]

        matched_spot = chat_with_openai(match_prompt)
        # print(matched_spot)

        if matched_spot in closest_spot_names:
            # print("true")
            detected_spot_name = matched_spot
            # print(detected_spot_name)
        else:
            # Fallback to full dataset search if OpenAI couldn't find a match in closest spots
            full_search_results = spots_df[spots_df["spot_name"].str.lower().str.contains(user_input.lower(), na=False)]
            detected_spot_name = full_search_results.iloc[0]["spot_name"] if not full_search_results.empty else None

        # Step 5: Handle matched spot or fallback
        if detected_spot_name:
            # Generate surf report dynamically
            report_prompt = [
                {"role": "system", "content": "You are a surf bot. Generate a surfer-style summary for the spot."},
                {"role": "user", "content": f"Can you generate a report for {detected_spot_name}?"},
            ]
            surf_report = brah.generate_local_brah_report(detected_spot_name, messages)
            # print(surf_report)
            final_report = chat_with_openai(report_prompt + [{"role": "assistant", "content": surf_report}])
            # print(final_report)

            # Ask the user dynamically if they want a board recommendation
            board_recommendation_prompt = [
                {"role": "system", "content": "You are a friendly surf bot. Ask the user if they would like a surfboard recommendation for the given conditions."},
                {"role": "assistant", "content": f"The report for {detected_spot_name} is ready. Would you like me to recommend the best type of surfboard for these conditions?"},
            ]
            board_question = chat_with_openai(board_recommendation_prompt)

            # Display the dynamic question to the user
            print(board_question)

            # Capture user input and let OpenAI interpret it dynamically
            user_response_context = [
                {"role": "system", "content": "You are a surf bot. Determine if the user wants a surfboard recommendation. If yes, respond with 'yes'. If no, respond with 'no'."},
                {"role": "user", "content": input("You: ").strip()},
            ]
            user_decision = chat_with_openai(user_response_context).lower()

            if user_decision == "yes":
                # Generate a board recommendation dynamically
                board = boards.board_selector(surf_report['Size'], surf_report['Quality'])
                board_type = board['Board Type']
                board_list = board['Boards']

                board_recommendation_context = [
                    {"role": "system", "content": "You are a surf bot that recommends a board type and a list of 5 booards from surf brands. Explain seclection and list out boards in a clean way. Explain briefly how the list relates to the surf report. List MODEL and BRAND and dims as in LxWxH"},
                    {"role": "user", "content": f"Here are the conditions for {detected_spot_name}:\n{surf_report}\n Here is the type of board {board_type}. Here is the list of reccomeneded boards \n {board_list}"},
                ]
                board_recommendation = chat_with_openai(board_recommendation_context)
                print(f"Bot: {board_recommendation}")
            else:
                # Dynamic response for not wanting a board recommendation
                no_recommendation_prompt = [
                    {"role": "system", "content": "You are a friendly surf bot. Respond positively if the user declines a surfboard recommendation."},
                    {"role": "assistant", "content": "No problem at all! Let me know if there's anything else I can help you with."},
                ]
                no_recommendation_response = chat_with_openai(no_recommendation_prompt)
                print(f"Bot: {no_recommendation_response}")

        else:
            # Dynamic fallback for unmatched input
            fallback_prompt = [
                {"role": "system", "content": "You are a friendly surf bot. If no match is found, respond in a helpful way."},
                {"role": "user", "content": user_input},
            ]
            fallback_response = chat_with_openai(fallback_prompt)
            print(fallback_response)


# Run the bot
if __name__ == "__main__":
    surf_bot()