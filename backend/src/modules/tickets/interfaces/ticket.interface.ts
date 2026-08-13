import { TicketSeverity } from '../enums/ticket-severity.enum';
import { TicketStatus } from '../enums/ticket-status.enum';

export interface Ticket {
  id: string;
  machine_id: string;
  reporter_id: string;
  engineer_id?: string | null;
  severity: TicketSeverity;
  status: TicketStatus;
  description: string;
  images_urls: string[];
  downtime_start: string;
  downtime_end?: string | null;
  claimed_at?: string | null;
  rejection_reason?: string | null;
  cancelled_at?: string | null;
  cancelled_reason?: string | null;
  created_at: string;
  updated_at: string;

  // Metadata hỗ trợ hiển thị phía client
  machine_name?: string;
  machine_code?: string;
  reporter_name?: string;
  reporter_email?: string;
  engineer_name?: string;
}

export interface FirestoreTicket {
  machine_id: string;
  reporter_id: string;
  engineer_id?: string | null;
  severity: TicketSeverity;
  status: TicketStatus;
  description: string;
  images_urls: string[];
  downtime_start: string;
  downtime_end?: string | null;
  claimed_at?: string | null;
  rejection_reason?: string | null;
  cancelled_at?: string | null;
  cancelled_reason?: string | null;
  machine_name?: string;
  machine_code?: string;
  reporter_name?: string;
  reporter_email?: string;
  engineer_name?: string;
  created_at: string;
  updated_at: string;
}
