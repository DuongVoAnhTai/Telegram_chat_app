import express from "express";
import { endCall, recentCall, startCall } from "../controllers/callConroller";
import { authenticateToken } from "../middlewares/authMiddleware";
const callRouter = express.Router();

callRouter.post('/start', startCall);
callRouter.post('/end', endCall);
callRouter.get('/recentCall/:userId', recentCall);

export default callRouter;