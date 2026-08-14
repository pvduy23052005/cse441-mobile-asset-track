import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { NotificationItem } from './interfaces/notification.interface';

export const TicketWsEvent = {
  CREATED: 'ticket_created',
  UPDATED: 'ticket_updated',
  CANCELLED: 'ticket_cancelled',
} as const;

export type TicketWsEventType =
  (typeof TicketWsEvent)[keyof typeof TicketWsEvent];

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class NotificationsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);

  handleConnection(client: Socket) {
    const userId = client.handshake.query.userId as string | undefined;
    const role = client.handshake.query.role as string | undefined;

    if (userId) {
      void client.join(userId);
      this.logger.log(`Client ${client.id} joined room ${userId}`);
    }

    if (role) {
      void client.join(role.toUpperCase());
      this.logger.log(`Client ${client.id} joined room ${role.toUpperCase()}`);
    }

    this.logger.log(`WebSocket Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`WebSocket Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('join')
  handleJoinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId?: string; role?: string },
  ) {
    if (data?.userId) {
      void client.join(data.userId);
      this.logger.log(`Client ${client.id} explicitly joined ${data.userId}`);
    }
    if (data?.role) {
      void client.join(data.role.toUpperCase());
      this.logger.log(
        `Client ${client.id} explicitly joined ${data.role.toUpperCase()}`,
      );
    }
    return { status: 'joined', ...data };
  }

  @SubscribeMessage('leave')
  handleLeaveRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId?: string; role?: string },
  ) {
    if (data?.userId) {
      void client.leave(data.userId);
    }
    if (data?.role) {
      void client.leave(data.role.toUpperCase());
    }
    return { status: 'left', ...data };
  }

  emitNotification(notification: NotificationItem) {
    if (!this.server) {
      this.logger.warn('WebSocket server chưa khởi tạo');
      return;
    }

    if (notification.user_id) {
      this.server
        .to(notification.user_id)
        .emit('notification', notification);
    }

    if (notification.target_role) {
      this.server
        .to(notification.target_role.toUpperCase())
        .emit('notification', notification);
    }

    if (!notification.user_id && !notification.target_role) {
      this.server.emit('notification', notification);
    }

    this.server.emit('new_notification', notification);
  }

  emitTicketEvent(event: TicketWsEventType, data: unknown) {
    if (!this.server) return;
    this.server.emit(event, data);
  }
}
