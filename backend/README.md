THE WAY TO CHECK DATABASE


docker ps

docker exec -it telegram_chat_app-mongo-1 bash

mongosh

use telegram_chat_app

show collections

db.messages.find().pretty()