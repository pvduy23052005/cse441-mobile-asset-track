export const TicketWsEvent = {
  CREATED: 'ticket_created',
  UPDATED: 'ticket_updated',
  CANCELLED: 'ticket_cancelled',
} as const;

export type TicketWsEventType =
  (typeof TicketWsEvent)[keyof typeof TicketWsEvent];
