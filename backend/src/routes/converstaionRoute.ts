import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { getUserConversations, createConversation, getConversationBetweenUsers } from "../controllers/conversationController";

const router = express.Router();

router.get('/fetchConversation/:id', authenticateToken, getUserConversations);

router.post('/create', authenticateToken, createConversation);

export default router;