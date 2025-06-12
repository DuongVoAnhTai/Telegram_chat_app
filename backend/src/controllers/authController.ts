import { Request, Response } from "express";
import User from '../models/userModel'
import bcrypt from 'bcrypt';
import { read } from "fs";
import jwt from 'jsonwebtoken';
import { config } from 'dotenv'
import cloudinary from "../config/cloudinary";
import { createNewConversationSavedMessageForNewUser } from "./conversationController";
import { StreamChat } from 'stream-chat';

config();

const SALT_ROUNDS: number = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'appsecretkey';

const serverClient = StreamChat.getInstance(process.env.STREAM_API_KEY!, process.env.STREAM_API_SECRET!);

export const register = async (req: Request, res: Response) => {
    const { fullName, email, password } = req.body;
    try {
        if (!fullName || !email || !password) {
            res.status(400).json({ message: "All fields are required" });
            return;
        }

        if (password.length < 6) {
            res.status(400).json({ message: "Password must be at least 6 characters" });
            return;
        }

        const user = await User.findOne({ email })
        if (user) {
            res.status(400).json({ message: "Email already exists" });
            return;
        }

        const salt = await bcrypt.genSalt(SALT_ROUNDS);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = new User({
            fullName: fullName,
            email: email,
            password: hashedPassword
        })
        if (newUser) {
            newUser.save();
            res.status(201).json({
                id: newUser._id,
                fullName: newUser.fullName,
                email: newUser.email,
            });
        } else {
            res.status(400).json({ message: "Invalid user data" });
            return;
        }
    } catch (error) {
        res.status(500).json({ message: "Failed" });
    }
};

export const login = async (req: Request, res: Response) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email });

        if (!user) {
            res.status(400).json({ message: "Invalid credential" });
            return;
        }

        const isPasswordCorrect = await bcrypt.compare(password, user.password);

        if (!isPasswordCorrect) {
            res.status(400).json({ message: "Invalid credential" });
            return;
        }
        await createNewConversationSavedMessageForNewUser(user._id.toString());
        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!, { expiresIn: "7d" });

        res.status(200).json({
            id: user._id,
            fullName: user.fullName,
            email: user.email,
            profilePoc: user.profilePic,
            token: token,
        });
    } catch (error) {
        res.status(500).json({ message: "Failed" + error });
    }
};

export const logout = (req: Request, res: Response) => {
    try {
        res.status(400).json({ message: "logged out successfuly" });
    } catch (error) {
        res.status(500).json({ message: "Failed" + error });
    }
};

export const updateProfile = async (req: any, res: any) => {
    try {
        const { fullName, profilePic, bio, dob } = req.body;
        const userId = req.user._id;

        let updateData: any = {};

        // Nếu có profilePic, upload lên Cloudinary
        /**
         * Flutter upload ảnh lên Cloudinary
         * Sau Cloudinary trả về url ảnh
         * Ta lấy link ảnh đó và lưu vào profilePic
         */
        if (profilePic && profilePic.startsWith('https://res.cloudinary.com')) {
            updateData.profilePic = profilePic;
        }

        // Cập nhật ten nếu có
        if (fullName !== undefined) {
            updateData.fullName = fullName;
        }

        // Cập nhật bio nếu có
        if (bio !== undefined) {
            updateData.bio = bio;
        }

        // Cập nhật dob nếu có
        if (dob !== undefined) {
            updateData.dob = dob;
        }

        // Nếu không có thay đổi gì, trả về thông báo
        if (Object.keys(updateData).length === 0) {
            res.status(400).json({ message: "No data to update" });
            return;
        }

        const updatedUser = await User.findByIdAndUpdate(userId, updateData, { new: true }).select("-password");

        res.status(200).json(updatedUser);

    } catch (error) {
        res.status(500).json({ message: "Failed" + error });
    }
};

export const checkAuth = async (req: any, res: any) => {
    try {
        res.status(200).json(req.user);
    } catch (error) {
        res.status(500).json({ message: "Failed" + error });
    }
};

//Tạo signature cho Cloudinary để upload ảnh
export const generateCloudinarySignature = async (req: any, res: any) => {
    try {
        const timestamp = Math.round(new Date().getTime() / 1000);
        const publicId = `user_profile_${timestamp}`;
        const signature = cloudinary.utils.api_sign_request(
            { timestamp, folder: 'profile_pics', public_id: publicId },
            process.env.CLOUDINARY_API_SECRET!
        );
        res.status(200).json({
            signature,
            timestamp,
            publicId,
            cloudName: process.env.CLOUDINARY_CLOUD_NAME,
            apiKey: process.env.CLOUDINARY_API_KEY,
        });
    } catch (error) {
        console.error('Signature generation error:', error);
        res.status(500).json({ message: 'Failed to generate signature' });
    }
};

export const getStreamToken = async (req: any, res: any) => {
    try {
        const userId = req.user._id.toString();
        if (!userId) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const token = serverClient.createToken(userId);
        res.status(200).json({ token });
    } catch (error) {
        console.error('Error generating Stream token:', error);
        res.status(500).json({ message: 'Failed to generate Stream token' });
    }
};