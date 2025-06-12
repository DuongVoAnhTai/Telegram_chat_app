import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";

import { getUserConversations, createConversation, getParticipantConversations, checkOrCreateConversation, removeMemberFromConversation, updateConversationName, removeConversation, addMembersToConversation } from "../controllers/conversationController";


const router = express.Router();

router.get('/fetchConversation', authenticateToken, getUserConversations);

router.post('/create', authenticateToken, createConversation);

router.post('/checkOrCreate', authenticateToken, checkOrCreateConversation);

router.post('/addMember/:conversationId',authenticateToken, addMembersToConversation);

router.delete('/:conversationId/removeUser',authenticateToken, removeMemberFromConversation);

router.delete('/:conversationId/removeConversation',authenticateToken, removeConversation);

router.put("/:conversationId", updateConversationName);

router.get('/getParticipants/:conversationId', getParticipantConversations);
export default router;