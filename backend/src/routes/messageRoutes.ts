import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { getMessages, sendMessage, getUsersForSidebar, getLastMessage } from "../controllers/MessageController";

const router = express.Router();

router.get("/", authenticateToken, getLastMessage);
router.get("/user", authenticateToken, getUsersForSidebar);
router.get("/:id", authenticateToken, getMessages);

router.post("/send/:id", authenticateToken, sendMessage);

export default router;