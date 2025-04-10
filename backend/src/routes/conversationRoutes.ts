import express from "express";
import { authenticateToken } from "../middlewares/authMiddleware";
import { getLastMessage } from "../controllers/MessageController";

const router = express.Router();

router.get("/", authenticateToken, getLastMessage);


export default router;