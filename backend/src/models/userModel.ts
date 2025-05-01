import mongoose, { Schema } from 'mongoose';

const userSchema = new Schema(
    {
        email: {
            type: String,
            required: true,
            unique: true,
        },
        fullName: String,
        password: {
            type: String,
            required: true,
            minLength: 6
        },
        profilePic: {
            type: String,
            default: "",
        }
    },
    { timestamps: true }
);

const User = mongoose.model("User", userSchema);

export default User;