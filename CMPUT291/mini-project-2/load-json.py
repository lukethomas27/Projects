import sys
import json
from pymongo import MongoClient


def load(port):
    #Connects the file to the corresponding port
    open_file = MongoClient(f"mongodb://localhost:{port}")
    database = open_file["291db"] #connects to "291db" in the mongo port
    collections = database.list_collection_names() #lists all the collections in the 291 database
    #checks if there is a tweets collection in the database already and either creates one or replaces one
    if "tweets" not in collections:
        database.create_collection("tweets")
    else:
        database["tweets"].drop()
        database.create_collection("tweets")
    return database

    
def insert(database, file_name):
    #opens the corresponding json file and transfers the data from the json file to the mongo database
    with open(file_name, 'r') as file:
        batch = []
        for i in file:
            split_data = json.loads(i)
            batch.append(split_data)
            #makes sure the max batch is 10k at a time
            if len(batch) >= 10000:
                database["tweets"].insert_many(batch)
                batch = []
        if batch:
            database["tweets"].insert_many(batch)
    
def main():
    #error check to make sure the right amount of arguments are passed
    if len(sys.argv) != 3:
            print(f"python3 load-json.py 'json file' 'port'")
            exit(100)
    #uses the functions made above to open and transfer into the mongo database
    file_name = sys.argv[1]
    port = int(sys.argv[2])
    data = load(port)
    insert(data, file_name)

if __name__ == "__main__":
    main()
