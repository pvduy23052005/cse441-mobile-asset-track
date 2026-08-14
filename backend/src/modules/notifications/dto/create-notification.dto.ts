import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { NotificationTypeEnum } from '../interfaces/notification.interface';

export class CreateNotificationDto {
  @IsOptional()
  @IsString()
  user_id?: string;

  @IsOptional()
  @IsString()
  target_role?: string;

  @IsNotEmpty({ message: 'Tiêu đề thông báo không được để trống' })
  @IsString()
  title: string;

  @IsNotEmpty({ message: 'Nội dung thông báo không được để trống' })
  @IsString()
  message: string;

  @IsNotEmpty()
  @IsEnum(NotificationTypeEnum, {
    message: 'Loại thông báo không hợp lệ (SOS, PM, APPROVAL, SYSTEM)',
  })
  type: NotificationTypeEnum;

  @IsOptional()
  @IsString()
  target_id?: string;
}
