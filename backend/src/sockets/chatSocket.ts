import { Server, Socket } from "socket.io";
import { Message } from "../app/models/Message";

export const setupSocket = (io: Server) => {
  io.on("connection", (socket: Socket) => {
    console.log("Client connected");

    socket.on("message", async (msg: { content: string; sender: string }) => {
      try {
        const newMessage = new Message({
          content: msg.content,
          sender: msg.sender,
        });
        await newMessage.save();
        io.emit("message", newMessage); // Gửi tin nhắn tới tất cả client
      } catch (err) {
        console.error("Error saving message:", err);
      }
    });

    socket.on("disconnect", () => console.log("Client disconnected"));
  });
};
