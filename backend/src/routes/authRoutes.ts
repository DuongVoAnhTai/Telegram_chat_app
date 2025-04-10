import { Router } from 'express';
import { register, login, logout, updateProfile, checkAuth } from '../controllers/authController';
import { authenticateToken } from '../middlewares/authMiddleware';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/logout', logout);

router.put('/update', authenticateToken, updateProfile);

router.get('/get', authenticateToken, checkAuth)

export default router;