import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { UserRole } from '../../../common/constants/user-role.enum';

export class CreateUserDto {
  @IsNotEmpty({ message: 'Email không được để trống' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email: string;

  @IsOptional()
  @IsString()
  password?: string;

  @IsNotEmpty({ message: 'Họ tên không được để trống' })
  @IsString()
  fullName: string;

  @IsNotEmpty({ message: 'Vai trò không được để trống' })
  @IsEnum(UserRole, {
    message: 'Vai trò không hợp lệ (operator, engineer, supervisor)',
  })
  role: UserRole;
}
