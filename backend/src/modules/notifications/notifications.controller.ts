import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import type { JwtAuthenticatedRequest } from '../auth/jwt-auth.guard';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationItem } from './interfaces/notification.interface';
import { NotificationsService } from './notifications.service';

@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post()
  async createNotification(
    @Body() dto: CreateNotificationDto,
  ): Promise<NotificationItem> {
    return this.notificationsService.createNotification(dto);
  }

  @Get()
  async getMyNotifications(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<NotificationItem[]> {
    const userId = req.user?.uid || req.user?.id;
    if (!userId) {
      throw new UnauthorizedException(
        'Không tìm thấy thông tin người dùng từ token',
      );
    }
    return this.notificationsService.getNotificationsForUser(
      userId,
      req.user?.role,
    );
  }

  @Get('unread-count')
  async getUnreadCount(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<{ unreadCount: number }> {
    const userId = req.user?.uid || req.user?.id;
    if (!userId) {
      throw new UnauthorizedException(
        'Không tìm thấy thông tin người dùng từ token',
      );
    }
    const count = await this.notificationsService.getUnreadCount(
      userId,
      req.user?.role,
    );
    return { unreadCount: count };
  }

  @Patch('read-all')
  async markAllAsRead(
    @Req() req: JwtAuthenticatedRequest,
  ): Promise<{ updatedCount: number }> {
    const userId = req.user?.uid || req.user?.id;
    if (!userId) {
      throw new UnauthorizedException(
        'Không tìm thấy thông tin người dùng từ token',
      );
    }
    return this.notificationsService.markAllAsRead(userId, req.user?.role);
  }

  @Patch(':id/read')
  async markAsRead(@Param('id') id: string): Promise<NotificationItem> {
    return this.notificationsService.markAsRead(id);
  }

  @Post('delete-batch')
  async deleteBatchNotifications(
    @Body('ids') ids: string[],
  ): Promise<{ deletedCount: number }> {
    return this.notificationsService.deleteMultipleNotifications(ids);
  }

  @Delete('batch')
  async deleteBatchNotificationsDelete(
    @Body('ids') ids: string[],
  ): Promise<{ deletedCount: number }> {
    return this.notificationsService.deleteMultipleNotifications(ids);
  }

  @Delete(':id')
  async deleteNotification(
    @Param('id') id: string,
  ): Promise<{ success: boolean }> {
    return this.notificationsService.deleteNotification(id);
  }
}

