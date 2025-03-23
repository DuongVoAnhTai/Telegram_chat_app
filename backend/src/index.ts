import express from "express";
import { createServer } from "http";
import { Server } from "socket.io";
import mongoose from "mongoose";
import { setupSocket } from "./sockets/chatSocket";
import dotenv from "dotenv";
import route from "./routes";
import { connect } from "./config/database";

// Đọc file .env
dotenv.config();

// Khởi tạo server
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer);

// Lấy các biến môi trường từ .env
const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/telegram_chat_app";
const PORT = parseInt(process.env.PORT || "3000", 10);

connect(MONGO_URI)// Kết nối MongoDB


// Sử dụng routes
route(app);

// Thiết lập WebSocket
setupSocket(io);

// Khởi động server
httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});