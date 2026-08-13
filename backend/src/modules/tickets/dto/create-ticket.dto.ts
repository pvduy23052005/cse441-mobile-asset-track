import {
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { TicketSeverity } from '../enums/ticket-severity.enum';

export class CreateTicketDto {
  @IsNotEmpty({ message: 'Mã thiết bị (machine_id) không được để trống' })
  @IsString({ message: 'machine_id phải là chuỗi' })
  machine_id: string;

  @IsNotEmpty({ message: 'Mô tả sự cố (description) không được để trống' })
  @IsString({ message: 'description phải là chuỗi' })
  description: string;

  @IsOptional()
  @IsEnum(TicketSeverity, {
    message:
      'Mức độ nghiêm trọng (severity) phải là một trong các giá trị: LOW, MEDIUM, HIGH, CRITICAL',
  })
  severity?: TicketSeverity;

  @IsOptional()
  @IsArray({ message: 'images_urls phải là một mảng các đường dẫn ảnh' })
  @IsString({
    each: true,
    message: 'Mỗi phần tử trong images_urls phải là chuỗi URL hợp lệ',
  })
  images_urls?: string[];

  @IsOptional()
  @IsString({ message: 'downtime_start phải là chuỗi thời gian hợp lệ' })
  downtime_start?: string;
}
