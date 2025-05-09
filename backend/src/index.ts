import dotenv from "dotenv";
import { connect } from "./config/database";
import { app, server } from "./config/socket";
import { json } from "express";
import authRoutes from "./routes/authRoutes";
import messageRoutes from './routes/messageRoute';
import conversationRoutes from "./routes/converstaionRoute";
import contactRoutes from "./routes/contactRoute";
import callRouter from "./routes/callRouters";

// Đọc file .env
dotenv.config();

app.use(json());

app.use('/auth', authRoutes);
app.use('/message', messageRoutes);
app.use('/conversation', conversationRoutes);
app.use('/contact', contactRoutes);
app.use('/callLog', callRouter);

// Khởi động server
const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/telegram_chat_app";
const PORT = parseInt(process.env.PORT || "3000", 10);
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  connect(MONGO_URI);
});