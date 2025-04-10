import { Request, Response } from "express";
import User from '../models/userModel'
import bcrypt from 'bcrypt';
import { read } from "fs";
import jwt from 'jsonwebtoken';
import { config } from 'dotenv'
import cloudinary from "../config/cloudinary";

config();

const SALT_ROUNDS: number = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'appsecretkey';

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
        const { profilePic } = req.body;
        const userId = req.user._id;

        if (!profilePic) {
            res.status(400).json({ message: "Profile pic is required" });
            return;
        }

        const uploadResponse = await cloudinary.uploader.upload(profilePic)
        const updatedUser = await User.findByIdAndUpdate(userId, { profilePic: uploadResponse.secure_url }, { new: true });

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