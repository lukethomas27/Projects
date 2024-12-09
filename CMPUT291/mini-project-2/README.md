[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/kKQ0md7N)
# Assignment4

# CMPUT 291 Mini Project 2 - Fall 2024
Group member names and ccids (3-4 members)  
  luke5, Luke Thomas  
  rzhi, Rayan Zhi  
  jyma1, James Ma  
  eason1, Eason Trang  

# Group work break-down strategy
James and Eason did Phase 1 load-json.py, compose tweet as well as put everything together in the main function. Luke did Phase 2 steps 1-2 and Rayan did the Phase 2 steps 3-4. Rayan also did the design document. 

# Code execution guide
Ensure pymongo is installed before hand and if it is not type in pip3 install pymongo. Go into terminal and type mongod --port "port number" so like mongod --port 27012. If that doesn't work, then do mongod --port 27012 --dbpath ~/(make a folder) so like mongod --port 27012 --dbpath ~/folder. Then do python3 load-json.py "json file name" "port number" like (python3 load-json.py 10.json 27012). After the JSON file is loded into Mongo DB, type in python3 operations.py "port number" like (python3 operations.py 27012) to interact with the database.

# Names of anyone you have collaborated with (as much as it is allowed within the course policy) or a line saying that you did not collaborate with anyone else.  
We did not collaborate with anyone. 

# More detail of any AI tool used.
ChatGPT was used to aid when merging files created by our team members in to operations.py due to certain variables not matching. The prompt was "Which variables don't match". We then changed whichever variable didn't match. All functions were created by our team members.
