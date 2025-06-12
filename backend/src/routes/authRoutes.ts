import { Router } from 'express';
import { register, login, logout, updateProfile, checkAuth, generateCloudinarySignature, getStreamToken } from '../controllers/authController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/logout', logout);

router.post('/stream-token', authenticateToken, getStreamToken);

router.put('/update', authenticateToken, updateProfile);

router.get('/get', authenticateToken, checkAuth)



router.get('/cloudinary-signature', authenticateToken, generateCloudinarySignature)

export default router;