import sys
from pymongo import MongoClient
from datetime import datetime

def db_connect(port):
    #connects to the server with the corresponding port
    client = MongoClient(f"mongodb://localhost:{port}")
    print("Connected to MongoDB!")
    return client["291db"]

def search_tweets(database):\
    #Give the user a prompt to search, error message if nothing is entered.
    collection = database.tweets
    keywords = input("Enter keywords to search for (separated by spaces): ").strip().split()
    if not keywords:
        print("No keywords entered. Please try again.")
        return

    #The function uses regular expressions to search for key words.
    query = {"$and": [{"content": {"$regex": f"\\b{kw}\\b", "$options": "i"}} for kw in keywords]}
    tweets = collection.find(query, {"id": 1, "date": 1, "content": 1, "user.username": 1})

    results = list(tweets)
    if not results:
        print("No matching tweets found.")
        return
    #lists tweets that match the descripion.
    print("\nMatching Tweets:")
    for idx, tweet in enumerate(results, 1):
        tweet_id = tweet.get("id", "Unknown")
        tweet_date = tweet.get("date", "Unknown")
        tweet_content = tweet.get("content", "Unknown")
        tweet_user = tweet.get("user", {}).get("username", "Unknown")

        print(f"[{idx}] ID: {tweet_id}, Date: {tweet_date}, Content: {tweet_content}, Username: {tweet_user}")

    # Allow the user to view full details of a tweet.
    selection = input("\nEnter the number of a tweet to view full details (or press Enter to return to the menu): ")
    if selection.isdigit() and 1 <= int(selection) <= len(results):
        selected_tweet_id = results[int(selection) - 1]["_id"]

        full_tweet = collection.find_one({"_id": selected_tweet_id})

        print("\nFull Details of Selected Tweet:")
        print(full_tweet)
    else:
        print("Returning to the menu.")


def search_users(database):
    #Give the user a prompt to search, error message if nothing is entered.
    collection = database.tweets
    keyword = input("Enter a keyword to search for in displayname or location: ").lower()
    if not keyword:
        print("No keyword entered. Please try again.")
        return
    #again, regular expressions used to search for users by displayname or location.
    query = {"$or": [
        {"user.displayname": {"$regex": keyword, "$options": "i"}},
        {"user.location": {"$regex": keyword, "$options": "i"}}
    ]}
    
    pipeline = [
        {"$match": query},
        {"$group": {
            "_id": "$user.username",
            "displayname": {"$first": "$user.displayname"},
            "location": {"$first": "$user.location"}
        }}
    ]
    users = collection.aggregate(pipeline)

    results = list(users)
    if not results:
        print("No matching users found.")
        return
    #list all users that match the given description
    print("\nMatching Users:")
    for idx, user in enumerate(results, 1):
        print(f"[{idx}] Username: {user['_id']}, Displayname: {user['displayname']}, Location: {user['location']}")

    # Allow the user to view full details of a user
    selection = input("\nEnter the number of a user to view full details (or press Enter to return to the menu): ")
    if selection.isdigit() and 1 <= int(selection) <= len(results):
        selected_user = results[int(selection) - 1]["_id"]
        full_user = list(collection.find({"user.username": selected_user}))
        print("\nFull Details of Selected User:")
        print(full_user)
    else:
        print("Returning to the menu.")

def list_top_tweets(collection, field, n):
    """
    Lists top n tweets sorted by a specified field in descending order.
    :param collection: MongoDB collection object
    :param field: The field to sort by ('retweetCount', 'likeCount', 'quoteCount')
    :param n: Number of top tweets to list
    """
    
    if field not in ['retweetCount', 'likeCount', 'quoteCount']:
        print("Invalid field. Please select 'retweetCount', 'likeCount', or 'quoteCount'.")
        return

        
    top_tweets = list(collection.find().sort([(field, -1)]).limit(n))
    for idx, tweet in enumerate(top_tweets, 1):
        tweet_id = tweet.get("id", "Unknown")
        tweet_date = tweet.get("date", "Unknown")
        tweet_content = tweet.get("content", "Unknown")
        tweet_user = tweet.get("user", {}).get("username", "Unknown")
        print(f"[{idx}] ID: {tweet_id}, Date: {tweet_date}, Content: {tweet_content}, Username: {tweet_user}")
        
    selection = input("\nEnter the number of a tweet to view full details (or press Enter to return to the menu): ").strip()
    if selection.isdigit() and 1 <= int(selection) <= len(top_tweets):
        selected_tweet = top_tweets[int(selection) - 1]
        print("\nFull Details of Selected Tweet:")
        print(selected_tweet)
    else:
        print("Returning to the menu.")



def list_top_users(collection, n):
    """
    Lists top n users sorted by followersCount in descending order and allows full detail view for a selected user.
    :param collection: MongoDB collection object
    :param n: Number of top users to list
    """
    top_users = list(collection.find({}, {'user': 1}).sort([('user.followersCount', -1)]).limit(n))

    for idx, user in enumerate(top_users, 1):
        username = user.get("user", {}).get("username", "Unknown")
        display_name = user.get("user", {}).get("displayname", "Unknown") 
        followers_count = user.get("user", {}).get("followersCount", "Unknown")
        print(f"[{idx}] Username: {username}, DisplayName: {display_name}, Followers: {followers_count}")

    selection = input("\nEnter the number of a user to view full details (or press Enter to skip): ").strip()
    if selection.isdigit() and 1 <= int(selection) <= len(top_users):
        selected_user = top_users[int(selection) - 1] 
        user_details = selected_user.get("user", {})
        print("\nFull Details of Selected User:")
        print(user_details)
    else:
        print("Returning to the menu.")



def compose_tweet(database):
    tweet = input("Enter the tweet: ").strip()
    if not tweet:
        print("Cannot tweet an empty tweet.")
        return

    new_tweet = {
        "url": None,
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "content": tweet,
        "renderedContent": tweet,
        "id": None,
        "user": {  # Nested dictionary for the user 
            "username": "291user",
            "displayname": None,
            "id": None,
            "description": None,
            "rawDescription": None,
            "descriptionUrls": None,
            "verified": None,
            "created": None,
            "followersCount": None,
            "friendsCount": None,
            "statusesCount": None,
            "favouritesCount": None,
            "listedCount": None,
            "mediaCount": None,
            "location": None,
            "protected": None,
            "profileImageUrl": None,
            "profileBannerUrl": None,
            "url": None,
            "linkTcourl": None
        },
        "outlinks": None,
        "tcooutlinks": None,
        "replyCount": None,
        "retweetCount": None,
        "likeCount": None,
        "quoteCount": None,
        "conversationId": None,
        "lang": None,
        "source": None,
        "sourceUrl": None,
        "sourceLabel": None,
        "media": None,
        "retweetedTweet": None,
        "quotedTweet": None,
        "mentionedUsers": None
    }

    result = database.tweets.insert_one(new_tweet)
    print("Tweet successfully composed!")


def main():
    #error check to make sure the amount of arguments are correct
    if len(sys.argv) != 2:
        print("Usage: python script.py <port>")
        sys.exit(1)

    port = sys.argv[1]
    database = db_connect(port)
    collection = database.tweets

    #uses the functions above to create a main menu with the 5 functions needed and a exit option
    while True:
        print("\n1. Search for tweets")
        print("2. Search for users")
        print("3. List top tweets")
        print("4. List top users")
        print("5. Compose a tweet")
        print("6. Exit")

        choice = input("Enter your choice: ").strip()
        if choice == "1":
            search_tweets(database)
        elif choice == "2":
            search_users(database)
        elif choice == "3":
            while True:
                num_tweets = input("Input how many top tweets you want to see: ")
                if num_tweets.isdigit():
                    num_tweets = int(num_tweets)
                    break
                else:
                    print("Invalid input. Please enter a number")
            fields = input("Type in either retweetCount, likeCount, quoteCount: ")
            list_top_tweets(collection, fields, num_tweets)
        elif choice == "4":
            while True:
                num_users = input("Input how many top users you want to see: ")
                if num_users.isdigit():
                    num_users = int(num_users)
                    break
                else:
                    print("Invalid input. Please enter a number")
            list_top_users(collection, num_users)
        elif choice == "5":
            compose_tweet(database)
            print()
        elif choice == "6":
            print("Exiting program. Goodbye!")
            break
        else:
            print("Invalid choice. Please try again.")


if __name__ == "__main__":
    main()
