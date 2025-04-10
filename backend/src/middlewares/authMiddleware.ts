import jwt, { JwtPayload } from 'jsonwebtoken'
import User from '../models/userModel';
import { config } from 'dotenv'

config();

export const authenticateToken = async (req: any, res: any, next: any) => {
    const token = req.header("Authorization")?.split(" ")[1];
    if (!token) return res.status(403).json({ message: "Access denied" });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET!);

        if (typeof decoded === "string" || !("userId" in decoded)) {
            return res.status(401).json({ message: "Invalid token" });
        }

        const user = await User.findById(decoded.userId).select("-password");
        if (!user) {
            res.status(404).json({ message: "Not found" });
            return;
        }
        req.user = user;
        next();
    } catch (error) {
        res.status(401).json({ message: "Invalid token" });
    }
};

export const removeToken = async (req: any, res: any, next: any) => {
    const token = req.header("Authorization")?.split(" ")[1];
    if (!token) return res.status(403).json({ message: "Access denied" });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET!);

        if (typeof decoded === "string" || !("userId" in decoded)) {
            return res.status(401).json({ message: "Invalid token" });
        }

        const user = await User.findById(decoded.userId).select("-password");
        if (!user) {
            res.status(404).json({ message: "Not found" });
            return;
        }
        req.user = user;
        next();
    } catch (error) {
        res.status(401).json({ message: "Invalid token" });
    }
};