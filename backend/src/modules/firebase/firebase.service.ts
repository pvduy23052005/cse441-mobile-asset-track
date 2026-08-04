import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { App, cert, getApp, getApps, initializeApp } from 'firebase-admin/app';
import { Auth, getAuth } from 'firebase-admin/auth';
import { Firestore, getFirestore } from 'firebase-admin/firestore';
import { getStorage, Storage } from 'firebase-admin/storage';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private firebaseApp: App;

  constructor(private readonly configService: ConfigService) {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    let privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

    if (privateKey) {
      privateKey = privateKey.replace(/\\n/g, '\n');
    }

    if (!getApps().length) {
      if (projectId && clientEmail && privateKey) {
        this.firebaseApp = initializeApp({
          credential: cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
      } else {
        this.logger.warn(
          'FIREBASE credentials missing in environment. Initializing default app.',
        );
        this.firebaseApp = initializeApp();
      }
    } else {
      this.firebaseApp = getApp();
    }
  }

  onModuleInit() {
    this.logger.log('Firebase Admin SDK initialized successfully!');
  }

  get app(): App {
    return this.firebaseApp;
  }

  get auth(): Auth {
    return getAuth(this.firebaseApp);
  }

  get firestore(): Firestore {
    return getFirestore(this.firebaseApp);
  }

  get storage(): Storage {
    return getStorage(this.firebaseApp);
  }
}
