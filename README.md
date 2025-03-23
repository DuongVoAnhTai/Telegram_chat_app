TELEGRAM_CHAT_APP

    ---> NOTION: ONLY RUN ANDROID EMULATOR



    *** REQUIRE:
        - Install mongodb compass
        - Install docker desktop



    *** USER MANUAL

        B1: Create .env file and ask leader
        B2: Open project Terminal in VSCode and cd .\backend. "D:\...\...\Telegram_chat_appp\backend"
        B3: run "npm install"
        B4: run "npm start" 
        B5: Open browse and browse to "localhost:3000/api/messages", if access successful, you will see "json" file
        B6: you can install "JSON Viewer extension" to see the code beautifully
        B7: Run main.dart in ANDROID EMULATOR and conduct text message. If success, database will create in your mongodb compass and you will see your message in database
        B8: Comeback terminal and Ctrl + C to exit 



    *** DOCKER
        When you test success, we will package image via docker

        B1: Open docker desktop
        B2: Open project Terminal in VSCode and cd in root "D:\...\...\Telegram_chat_app"
        B3: Conduct build docker-compose. Run "docker-compose -p telegram_chat_app up -d --build"
        B4: When build is successful, you will see your images in the tab image in docker desktop, conduct run "mongo" and "telegram_chat_app_backend" image
        B5: Open Containers tab in docker desktop, you will see container that you build from image
        B6: Open browse and browse to "localhost:3000/api/messages", if access successful, you will see "json" file
        B7: Run main.dart in ANDROID EMULATOR and conduct text message. If success, database will create in your mongodb CONTAINER and you will see your message in database
        B8: You can check container run in terminal by run "docker ps"



    => The next time, you only open docker desktop, open container tab and run container that you build from image without run "npm start" in terminal backend

   