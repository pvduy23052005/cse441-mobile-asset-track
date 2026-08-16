import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  UseGuards,
  Query,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import 'multer';
import { UploadService } from './upload.service';
import { UploadResponseDto } from './dto/upload-response.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { MAX_FILE_SIZE, isImageFile } from './constants/upload.constant';

const imageFileFilter = (
  _req: any,
  file: Express.Multer.File,
  callback: (error: Error | null, acceptFile: boolean) => void,
) => {
  if (!file || !isImageFile(file.mimetype, file.originalname)) {
    return callback(
      new BadRequestException(
        'Chỉ cho phép tải lên file hình ảnh (jpg, jpeg, png, gif, webp, svg, heic, heif, bmp)',
      ),
      false,
    );
  }
  callback(null, true);
};

@Controller('upload')
@UseGuards(JwtAuthGuard)
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post()
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: MAX_FILE_SIZE },
      fileFilter: imageFileFilter,
    }),
  )
  async upload(
    @UploadedFile() file: Express.Multer.File,
    @Query('folder') folder?: string,
  ): Promise<UploadResponseDto> {
    if (!file) {
      throw new BadRequestException(
        'Vui lòng cung cấp file trong trường "file"',
      );
    }
    return this.uploadService.uploadFile(file, folder || 'uploads');
  }
}
