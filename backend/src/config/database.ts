import mongoose from "mongoose";

async function connect(MONGO_URI: string): Promise<void> {
    try {
        await mongoose.connect(MONGO_URI, {
            user: "",
            pass: "",
        });
        console.log("Connected to MongoDB");
    } catch (err) {
        console.error("MongoDB connection error:", err)
    }
}

export { connect };