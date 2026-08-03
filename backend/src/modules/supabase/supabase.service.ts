import { ConfigService } from '@nestjs/config';
import { createClient } from '@supabase/supabase-js';
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';

@Injectable()
export class SupabaseService implements OnModuleInit {
  private readonly logger = new Logger(SupabaseService.name);
  private supabaseClient: ReturnType<typeof createClient>;

  constructor(private readonly configService: ConfigService) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      this.logger.warn(
        'SUPABASE_URL or SUPABASE_KEY is missing in environment variables. Please check your .env file.',
      );
    }

    this.supabaseClient = createClient(supabaseUrl || '', supabaseKey || '');
  }

  async onModuleInit() {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      return;
    }

    try {
      const response = await fetch(`${supabaseUrl}/rest/v1/`, {
        method: 'GET',
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
        },
      });

      if (response.ok) {
        this.logger.log('Successfully connected to Supabase!');
      } else {
        this.logger.error(
          `Failed to connect to Supabase: ${response.status} ${response.statusText}`,
        );
      }
    } catch (error) {
      this.logger.error('Error connecting to Supabase:', error);
    }
  }

  get client(): ReturnType<typeof createClient> {
    return this.supabaseClient;
  }
}
