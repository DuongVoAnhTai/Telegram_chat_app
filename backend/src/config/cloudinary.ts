import { v2 as cloudinary } from "cloudinary"
import { config } from 'dotenv'

config();

cloudinary.config({
    cloud_name: process.env.CLOUNDINAR_CLOUND_NAME,
    api_key: process.env.CLOUNDINAR_APIKEY,
    api_secret: process.env.CLOUNDINAR_API_SECRET,
});

export default cloudinary;