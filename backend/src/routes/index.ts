import { Express } from 'express';
import messageRouter from './messageRoutes';

function route(app: Express): void{
    app.use('/api', messageRouter);
}

export default route;