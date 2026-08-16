import {
  Injectable,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import * as path from 'path';
import * as crypto from 'crypto';
import 'multer';
import sharp from 'sharp';
import { UploadResponseDto } from './dto/upload-response.dto';
import {
  detectFileCategory,
  MAX_FILE_SIZE,
  FIXED_IMAGE_WIDTH,
  FIXED_IMAGE_HEIGHT,
  IMAGE_COMPRESS_QUALITY,
} from './constants/upload.constant';

@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);
  private readonly s3Client: S3Client;
  private readonly bucketName: string;
  private readonly publicUrl: string;

  constructor(private readonly configService: ConfigService) {
    const accountId = this.configService
      .get<string>('R2_ACCOUNT_ID', '')
      .replace(/"/g, '')
      .trim();
    const accessKeyId = this.configService
      .get<string>('R2_ACCESS_KEY_ID', '')
      .replace(/"/g, '')
      .trim();
    const secretAccessKey = this.configService
      .get<string>('R2_SECRET_ACCESS_KEY', '')
      .replace(/"/g, '')
      .trim();

    this.bucketName = (
      this.configService.get<string>('R2_BUCKET_NAME', 'asset-track') ||
      'asset-track'
    )
      .replace(/"/g, '')
      .trim();

    const rawPublicUrl =
      this.configService.get<string>('R2_PUBLIC_URL') ||
      this.configService.get<string>('R2_PUBLIC_UR') ||
      '';

    this.publicUrl = rawPublicUrl.replace(/"/g, '').replace(/\/+$/, '').trim();

    if (!accountId || !accessKeyId || !secretAccessKey) {
      this.logger.warn(
        'Cloudflare R2 credentials (R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY) are not fully configured!',
      );
    }

    this.s3Client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });
  }

  private generateFileKey(
    originalName: string,
    folder: string = 'uploads',
  ): string {
    const ext = path.extname(originalName).toLowerCase();
    const baseName = path
      .basename(originalName, ext)
      .replace(/[^a-zA-Z0-9_-]/g, '_')
      .slice(0, 30);
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomHex = crypto.randomBytes(4).toString('hex');
    const cleanFolder = folder.replace(/^\/+|\/+$/g, '').trim();

    const fileName = `${dateStr}_${Date.now()}_${randomHex}_${baseName}${ext}`;
    return cleanFolder ? `${cleanFolder}/${fileName}` : fileName;
  }

  async uploadFile(
    file: Express.Multer.File,
    folder: string = 'uploads',
  ): Promise<UploadResponseDto> {
    if (!file || !file.buffer) {
      throw new BadRequestException('Vui lòng chọn file hợp lệ để tải lên');
    }

    if (file.size > MAX_FILE_SIZE) {
      const maxMb = (MAX_FILE_SIZE / (1024 * 1024)).toFixed(0);
      throw new BadRequestException(
        `Kích thước file vượt quá giới hạn tối đa ${maxMb}MB`,
      );
    }

    const originalName = Buffer.from(
      file.originalname || 'file',
      'latin1',
    ).toString('utf8');
    const category = detectFileCategory(file.mimetype, originalName);
    if (category !== 'image') {
      throw new BadRequestException(
        'Chỉ cho phép tải lên file hình ảnh (jpg, jpeg, png, gif, webp, svg, heic, heif, bmp)',
      );
    }

    const key = this.generateFileKey(originalName, folder);

    let processedBuffer = file.buffer;
    let mimeType = file.mimetype || 'image/jpeg';
    if (
      mimeType === 'application/octet-stream' ||
      !mimeType.startsWith('image/')
    ) {
      const ext = path.extname(originalName).toLowerCase();
      if (ext === '.png') mimeType = 'image/png';
      else if (ext === '.webp') mimeType = 'image/webp';
      else if (ext === '.gif') mimeType = 'image/gif';
      else if (ext === '.svg') mimeType = 'image/svg+xml';
      else mimeType = 'image/jpeg';
    }

    try {
      let pipeline = sharp(file.buffer).rotate().resize({
        width: FIXED_IMAGE_WIDTH,
        height: FIXED_IMAGE_HEIGHT,
        fit: 'inside',
        withoutEnlargement: true,
      });

      if (mimeType === 'image/jpeg' || mimeType === 'image/jpg') {
        pipeline = pipeline.jpeg({
          quality: IMAGE_COMPRESS_QUALITY,
          mozjpeg: true,
        });
      } else if (mimeType === 'image/png') {
        pipeline = pipeline.png({
          quality: IMAGE_COMPRESS_QUALITY,
          compressionLevel: 8,
        });
      } else if (mimeType === 'image/webp') {
        pipeline = pipeline.webp({ quality: IMAGE_COMPRESS_QUALITY });
      }

      processedBuffer = await pipeline.toBuffer();
    } catch (resizeError) {
      this.logger.warn(
        `Không thể xử lý resize ảnh bằng sharp: ${resizeError}. Sử dụng buffer gốc.`,
      );
      processedBuffer = file.buffer;
    }

    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        Body: processedBuffer,
        ContentType: mimeType,
        ContentDisposition: 'inline',
      });

      await this.s3Client.send(command);

      const fileUrl = this.publicUrl ? `${this.publicUrl}/${key}` : key;

      return {
        url: fileUrl,
        key,
        name: originalName,
        size: processedBuffer.length,
        mimeType,
        category,
        uploadedAt: new Date().toISOString(),
      };
    } catch (error) {
      this.logger.error(
        `Error uploading to Cloudflare R2: ${error}`,
        (error as Error)?.stack,
      );
      throw new InternalServerErrorException(
        'Lỗi hệ thống khi tải file lên Cloudflare R2',
      );
    }
  }

  async uploadMultipleFiles(
    files: Express.Multer.File[],
    folder: string = 'uploads',
  ): Promise<UploadResponseDto[]> {
    if (!files || files.length === 0) {
      throw new BadRequestException('Vui lòng cung cấp ít nhất một file');
    }

    return Promise.all(files.map((file) => this.uploadFile(file, folder)));
  }

  async deleteFile(
    key: string,
  ): Promise<{ success: boolean; key: string; message: string }> {
    if (!key || !key.trim()) {
      throw new BadRequestException('Vui lòng cung cấp key của file cần xóa');
    }

    const cleanKey = key.trim().replace(/^\/+/, '');

    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: cleanKey,
      });

      await this.s3Client.send(command);

      return {
        success: true,
        key: cleanKey,
        message: 'Xóa file thành công khỏi Cloudflare R2',
      };
    } catch (error) {
      this.logger.error(`Error deleting file from Cloudflare R2: ${error}`);
      throw new InternalServerErrorException(
        'Lỗi hệ thống khi xóa file trên Cloudflare R2',
      );
    }
  }
}
