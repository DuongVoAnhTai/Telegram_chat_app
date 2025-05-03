import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { getUserConversations, createConversation, getConversationBetweenUsers, checkOrCreateConversation } from "../controllers/conversationController";

const router = express.Router();

router.get('/fetchConversation/:id', authenticateToken, getUserConversations);

router.post('/create', authenticateToken, createConversation);

router.post('/checkOrCreate', authenticateToken, checkOrCreateConversation);

export default router;