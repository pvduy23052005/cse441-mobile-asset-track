import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

export interface Machine {
  id: string;
  code: string;
  name: string;
  model: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications: Record<string, any>;
  status: string;
  running_hours: number;
  createdAt?: string;
  updatedAt?: string;
  [key: string]: any;
}

export interface FirestoreMachine {
  code?: string;
  name?: string;
  model?: string;
  location?: string;
  next_maintenance_hours?: number;
  specifications?: Record<string, any>;
  status?: string;
  running_hours?: number;
  createdAt?: string;
  updatedAt?: string;
}

@Injectable()
export class MachineService {
  private readonly logger = new Logger(MachineService.name);
  private readonly collectionName = 'machines';

  constructor(private readonly firebaseService: FirebaseService) {}

  async getAllMachines(): Promise<Machine[]> {
    try {
      const snapshot = await this.firebaseService.firestore
        .collection(this.collectionName)
        .get();

      return snapshot.docs.map((doc) => {
        const data = doc.data() as FirestoreMachine;
        return {
          id: doc.id,
          code: data.code || '',
          name: data.name || '',
          model: data.model || '',
          location: data.location || '',
          next_maintenance_hours: data.next_maintenance_hours,
          specifications: data.specifications || {},
          status: data.status || 'ACTIVE',
          running_hours: data.running_hours ?? 0,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        };
      });
    } catch (error) {
      this.logger.error(`Error fetching machines from Firestore: ${error}`);
      return [];
    }
  }

  async getMachineById(id: string): Promise<Machine> {
    const doc = await this.firebaseService.firestore
      .collection(this.collectionName)
      .doc(id)
      .get();

    if (!doc.exists) {
      throw new NotFoundException(`Machine with ID '${id}' not found`);
    }

    const data = (doc.data() as FirestoreMachine) || {};
    return {
      id: doc.id,
      code: data.code || '',
      name: data.name || '',
      model: data.model || '',
      location: data.location || '',
      next_maintenance_hours: data.next_maintenance_hours,
      specifications: data.specifications || {},
      status: data.status || 'ACTIVE',
      running_hours: data.running_hours ?? 0,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    };
  }
}
