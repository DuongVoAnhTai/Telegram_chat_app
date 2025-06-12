import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";

import { getUserConversations, createConversation, getConversationBetweenUsers, checkOrCreateConversation, addMemberToConversation, removeMemberFromConversation, updateConversationName } from "../controllers/conversationController";


const router = express.Router();

router.get('/fetchConversation/:id', authenticateToken, getUserConversations);

router.post('/create', authenticateToken, createConversation);

router.post('/checkOrCreate', authenticateToken, checkOrCreateConversation);

router.post('/addMember/:conversationId',authenticateToken, addMemberToConversation);

router.delete('/:conversationId/removeUser', removeMemberFromConversation);

router.put("/:conversationId", updateConversationName);

router.get('/getParticipants/:conversationId', getParticipantConversations);
export default router;