import { Request, Response } from "express";
import Conversation from "../models/conversationModel";
import mongoose from "mongoose";
import User from "../models/userModel";

export const createConversation = async (req: any, res: any) => {
  try {
    let userId = null;
    if (req.user) {
      userId = req.user._id;
    }

    // const { participants } = req.body;

    // const otherParticipants = participants.filter(
    //     (participant: mongoose.Types.ObjectId) => participant.toString() !== userId.toString()
    // );
    // var newConversation = new Conversation({ name: participants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
    // if (participants.length == 2) {
    //     newConversation = new Conversation({ name: otherParticipants.map((participant: mongoose.Types.ObjectId) => participant.toString()).join(', '), participants });
    // }
    // const savedConversation = await newConversation.save();

    const { participants } = req.body;

    // Remove the current user from the list for naming
    const otherParticipants = participants.filter(
      (participant: mongoose.Types.ObjectId) =>
        participant.toString() !== userId.toString()
    );

    // Fetch user names from DB
    const users = await User.find({ _id: { $in: participants } }).select(
      "fullName"
    );

    const nameMap = new Map(
      users.map((user) => [user._id.toString(), user.fullName])
    );

    const { groupName } = req.body;
    let conversationName = "";
    if (!groupName) {
      // If groupName is provided, use it; otherwise, generate a default name
      // Default conversation name: all participants
      conversationName = participants
        .map(
          (id: mongoose.Types.ObjectId) =>
            nameMap.get(id.toString()) || "Unknown"
        )
        .join(", ");

      // If it's a one-on-one, exclude current user
      if (participants.length === 2) {
        conversationName = otherParticipants
          .map(
            (id: mongoose.Types.ObjectId) =>
              nameMap.get(id.toString()) || "Unknown"
          )
          .join(", ");
      }
    } else {
      // If groupName is provided, use it
      conversationName = groupName;
    }

    const newConversation = new Conversation({
      name: conversationName,
      participants,
      ownerID: req.user._id,
    });

    const savedConversation = await newConversation.save();

    res.status(201).json(savedConversation);
  } catch (error) {
    res.status(500).json({ message: "Failed to create conversation", error });
  }
};

export const addMembersToConversation = async (req: Request, res: Response) => {
  try {
    const { conversationId } = req.params;
    const { userIds } = req.body;

    if (
      !conversationId ||
      !Array.isArray(userIds) ||
      userIds.length === 0 ||
      typeof conversationId !== "string" ||
      !userIds.every((id) => typeof id === "string")
    ) {
      res
        .status(400)
        .json({
          message:
            "conversationId must be a string and userIds must be a non-empty array of strings",
        });
      return;
    }

    const conversationObjectId = new mongoose.Types.ObjectId(conversationId);
    const newMemberObjectIds = userIds.map(
      (id) => new mongoose.Types.ObjectId(id)
    );

    const conversation = await Conversation.findById(conversationObjectId);
    if (!conversation) {
      console.log("Conversation not found");
      res.status(404).json({ message: "Conversation not found" });
      return;
    }

    const currentParticipantIds = new Set(
      conversation.participants.map((id: mongoose.Types.ObjectId) =>
        id.toString()
      )
    );

    const membersToAdd = newMemberObjectIds.filter(
      (id) => !currentParticipantIds.has(id.toString())
    );

    if (membersToAdd.length === 0) {
      res
        .status(400)
        .json({
          message: "All users are already participants in the conversation",
        });
      return;
    }

    conversation.participants.push(...membersToAdd);

    // Cập nhật tên (nếu là group)
    const users = await User.find({
      _id: { $in: conversation.participants },
    }).select("fullName");
    const nameMap = new Map(
      users.map((user) => [user._id.toString(), user.fullName])
    );

    if (!conversation.name || conversation.name.trim() === "") {
      conversation.name = conversation.participants
        .map((id) => nameMap.get(id.toString()) || "Unknown")
        .join(", ");
    }

    const updatedConversation = await conversation.save();

    res.status(200).json(updatedConversation);
  } catch (error) {
    console.error("Error in addMembersToConversation:", error);
    res
      .status(500)
      .json({ message: "Failed to add members to conversation", error });
  }
};

export const removeMemberFromConversation = async (
  req: Request,
  res: Response
) => {
  try {
    const { conversationId } = req.params;
    const { memberIdToRemove } = req.body;

    if (
      !conversationId ||
      !memberIdToRemove ||
      typeof conversationId !== "string" ||
      typeof memberIdToRemove !== "string"
    ) {
      res
        .status(400)
        .json({
          message: "conversationId and newMemberId must be non-empty strings",
        });
      return;
    }

    const conversationObjectId = new mongoose.Types.ObjectId(conversationId);
    const memberObjectId = new mongoose.Types.ObjectId(memberIdToRemove);

    const conversation = await Conversation.findById(conversationObjectId);
    if (!conversation) {
      res.status(404).json({ message: "Conversation not found" });
      return;
    }

    const isParticipant = conversation.participants.some(
      (participantId: mongoose.Types.ObjectId) =>
        participantId.equals(memberObjectId)
    );

    if (!isParticipant) {
      res
        .status(400)
        .json({ message: "User is not a participant in the conversation" });
      return;
    }

    // Xoá thành viên
    conversation.participants = conversation.participants.filter(
      (participantId: mongoose.Types.ObjectId) =>
        !participantId.equals(memberObjectId)
    );

    const updatedConversation = await conversation.save();

    res.status(200).json(updatedConversation);
  } catch (error) {
    console.error("Error in removeMemberFromConversation:", error);
    res
      .status(500)
      .json({ message: "Failed to remove member from conversation", error });
  }
};

// update conversation name
export const updateConversationName = async (req: Request, res: Response) => {
  const { conversationId } = req.params;
  const { name } = req.body;

  const conversationObjectId = new mongoose.Types.ObjectId(conversationId);

  const conversation = await Conversation.findById(conversationObjectId);
  if (!conversation) {
    res.status(404).json({ message: "Conversation not found" });
    return;
  }

  if (name) {
    conversation.name = name;
    await conversation.save();
  }

  res.status(200).json({ conversation });
};

export const updateConversationProfilePic = async (
  req: Request,
  res: Response
) => {
  try {
    const { conversationId } = req.params;
    const { profilePic } = req.body;

    const conversationObjectId = new mongoose.Types.ObjectId(conversationId);

    const conversation = await Conversation.findById(conversationObjectId);
    if (!conversation) {
      res.status(404).json({ message: "Conversation not found" });
      return;
    }

    if (profilePic && profilePic.startsWith('https://res.cloudinary.com')) {
      conversation.profilePic = profilePic;
      await conversation.save();
    }

    res.status(200).json({ conversation });
  } catch (error) {
    console.error("Error updating conversation profile picture:", error);
    res
      .status(500)
      .json({ message: "Failed to update profile picture", error });
  }
};

// Get conversations of a user
export const getUserConversations = async (req: any, res: Response) => {
  try {
    const userId = req.user._id;
    const conversations = await Conversation.find({
      participants: { $in: [userId] },
      $or: [{ isDeleted: false }, { isDeleted: { $exists: false } }],
    }).populate("participants", "fullName profilePic");
    res.status(200).json(conversations);
  } catch (error) {
    1;
    res.status(500).json({ message: "Failed to fetch conversations", error });
  }
};

// Get a conversation between two users
export const getConversationBetweenUsers = async (
  req: Request,
  res: Response
) => {
  try {
    const { userId1, userId2 } = req.body;

    const conversation = await Conversation.findOne({
      participants: { $all: [userId1, userId2] },
    });

    if (!conversation) {
      res.status(404).json({ message: "Conversation not found" });
      return;
    }

    res.status(200).json(conversation);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch conversation", error });
  }
};
export const getParticipantConversations = async (
  req: Request,
  res: Response
) => {
  try {
    const { conversationId } = req.params;
    const conversation = await Conversation.findOne({
      _id: conversationId,
    }).populate("participants", "fullName profilePic");
    if (!conversation) {
      res.status(404).json({ message: "Conversation not found" });
      return;
    }
    // Trích xuất _id và fullName từ participants
    const participants = conversation.participants.map((participant: any) => ({
      _id: participant._id.toString(),
      fullName: participant.fullName,
      profilePic: participant.profilePic,
    }));
    res.status(200).json({ participants });
  } catch (error) {
    console.error("Error fetching participants:", error);
    res.status(500).json({ message: "Failed to fetch participants", error });
  }
};
export const checkOrCreateConversation = async (req: any, res: any) => {
  try {
    let userId = null;
    if (req.user) {
      userId = req.user._id;
    }

    const { contactId } = req.body;

    // Check if the conversation already exists
    const existingConversation = await Conversation.findOne({
      participants: { $all: [userId, contactId] },
      $expr: { $eq: [{ $size: "$participants" }, 2] },
    });

    if (existingConversation) {
      return res.status(200).json(existingConversation);
    }

    // If not, create a new conversation
    const newConversation = new Conversation({
      participants: [userId, contactId],
    });
    const savedConversation = await newConversation.save();

    res.status(201).json(savedConversation);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Failed to check or create conversation", error });
  }
};

export const createNewConversationSavedMessageForNewUser = async (
  userId: string
) => {
  try {
    const existing = await Conversation.findOne({
      participants: [userId],
      name: "Saved Messages",
    });
    if (existing) {
      return existing;
    }
    const newConversation = await Conversation.create({
      name: "Saved Messages",
      participants: [userId],
      lastMessage: "",
    });
    newConversation.savedMessagesId =
      newConversation._id as mongoose.Types.ObjectId;
    await newConversation.save();

    return newConversation;
  } catch (error) {
    console.error("Error creating saved message conversation:", error);
    throw error;
  }
};

export const removeConversation = async (req: any, res: Response) => {
  try {
    const { conversationId } = req.params;
    const ownerId = req.user._id;

    const conversationObjectId = new mongoose.Types.ObjectId(conversationId);

    const conversation = await Conversation.findById(conversationObjectId);

    if (!conversation) {
      res.status(404).json({ message: "Conversation not found" });
      return;
    }

    if (!conversation.ownerID.equals(ownerId)) {
      res
        .status(403)
        .json({ message: "You are not the owner of this conversation" });
      return;
    }

    await Conversation.updateOne(
      { _id: conversationObjectId },
      { $set: { isDeleted: true, deletedAt: new Date() } }
    );

    res.status(200).json({ message: "Remove conversation successfully" });
  } catch (error) {
    console.error("removeConversation error:", error);
    res.status(500).json({ message: "Internal server error", error });
  }
};
