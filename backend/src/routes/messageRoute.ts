import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { getMessages, sendMessage, getUsersForSidebar } from "../controllers/messageController";

const router = express.Router();

router.get("/user", authenticateToken, getUsersForSidebar);
router.get("/:id", authenticateToken, getMessages);

router.post("/send/:id", authenticateToken, sendMessage);

export default router;