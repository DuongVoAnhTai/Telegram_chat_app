import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { fetchContacts, createContact } from "../controllers/contactController";

const router = express.Router();

router.get('/fetchContact', authenticateToken, fetchContacts);

router.post('/addContact', authenticateToken, createContact);

export default router;