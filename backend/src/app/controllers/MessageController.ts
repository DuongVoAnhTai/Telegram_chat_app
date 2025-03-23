import { Request, Response, NextFunction } from "express";
import { Message } from "../models/Message";

class MessageController {
  show(req: Request, res: Response, next: NextFunction): void {
    Message.find({})
      .then((data) => {
        res.json(data);
      })
      .catch(next);
  }
}

export default new MessageController();
