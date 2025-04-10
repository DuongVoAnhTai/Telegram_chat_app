import { Express } from 'express';
import messageRouter from './messageRoutes';
import authRouter from './authRoutes';


function route(app: Express): void {
    app.use('/conversation', messageRouter);
    app.use('/auth', authRouter);
}

export default route;