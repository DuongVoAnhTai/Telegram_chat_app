import Message from "../models/messageModel";
import User from "../models/userModel";
import cloudinary from "../config/cloudinary";

export const getUsersForSidebar = async (req: any, res: any) => {
  try {
    const loggedInUserId = req.user.id;
    const filteredUsers = await User.find({ _id: { $ne: loggedInUserId } })

    res.status(200).json(filteredUsers);
  } catch (error) {
    res.status(500).json({ error: "internal server error" });
  }
}

export const getMessages = async (req: any, res: any) => {
  try {
    const { id: userToChatId } = req.params;
    const senderId = req.user._id;

    const messages = await Message.find({
      $or: [
        { senderId: senderId, receiverId: userToChatId },
        { senderId: userToChatId, receiverId: senderId }
      ]
    })
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ error: "internal server error" });
  }
}

export const getLastMessage = async (req: any, res: any) => {
  try {
    const { id: userToChatId } = req.params;
    const senderId = req.user._id;

    const messages = await Message.find({
      $or: [
        { senderId: senderId, receiverId: userToChatId },
        { senderId: userToChatId, receiverId: senderId }
      ]
    })
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ error: "internal server error" });
  }
}

export const sendMessage = async (req: any, res: any) => {
  try {
    const { text, image } = req.body;
    const { id: receiverId } = req.params;
    const senderId = req.user._id;

    let imageUrl;
    if (image) {
      const uploadResponse = await cloudinary.uploader.upload(image);
      imageUrl = uploadResponse.secure_url;
    }

    const newMessage = new Message({
      senderId,
      receiverId,
      text,
      image: imageUrl,
    });

    await newMessage.save();

    //TODO: realtime functionality gose here => socket.io

    res.status(201).json(newMessage);

  } catch (error) {
    res.status(500).json({ error: "internal server error" });
    console.log(error);
  }
}