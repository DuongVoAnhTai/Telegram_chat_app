import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { fetchContacts, createContact, deleteContact } from "../controllers/contactController";

const router = express.Router();

router.get('/fetchContact', authenticateToken, fetchContacts);

router.post('/addContact', authenticateToken, createContact);

router.delete('/:id', authenticateToken, deleteContact);

export default router;