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
import { UserRole } from '../../common/constants/user-role.enum';
import { NotificationItem } from './interfaces/notification.interface';
import type { TicketWsEventType } from './notification.event';

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

  private normalizeRole(role: string): string | null {
    const cleanRole = role.toLowerCase().trim();
    const validRoles = Object.values(UserRole) as string[];
    if (validRoles.includes(cleanRole)) {
      return cleanRole.toUpperCase();
    }
    return null;
  }

  handleConnection(client: Socket) {
    const userId = client.handshake.query.userId as string | undefined;
    const role = client.handshake.query.role as string | undefined;

    if (userId) {
      void client.join(userId);
      this.logger.log(`Client ${client.id} joined room ${userId}`);
    }

    if (role) {
      const normalizedRole = this.normalizeRole(role);
      if (normalizedRole) {
        void client.join(normalizedRole);
        this.logger.log(`Client ${client.id} joined room ${normalizedRole}`);
      }
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
      const normalizedRole = this.normalizeRole(data.role);
      if (normalizedRole) {
        void client.join(normalizedRole);
        this.logger.log(
          `Client ${client.id} explicitly joined ${normalizedRole}`,
        );
      }
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
      const normalizedRole = this.normalizeRole(data.role);
      if (normalizedRole) {
        void client.leave(normalizedRole);
      }
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
      const normalizedRole = this.normalizeRole(notification.target_role);
      if (normalizedRole) {
        this.server.to(normalizedRole).emit('notification', notification);
      }
    }

    if (!notification.user_id && !notification.target_role) {
      this.server.emit('notification', notification);
    }

    this.server.emit('new_notification', notification);
  }

  emitTicketEvent(
    event: TicketWsEventType,
    data: unknown,
    targetRole?: string,
  ) {
    if (!this.server) return;

    if (targetRole) {
      const normalizedRole = this.normalizeRole(targetRole);
      if (normalizedRole) {
        this.server.to(normalizedRole).emit(event, data);
        return;
      }
    }

    this.server.emit(event, data);
  }
}
