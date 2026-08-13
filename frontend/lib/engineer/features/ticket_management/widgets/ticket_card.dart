import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final VoidCallback onClaim;
  final VoidCallback onComplete;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    required this.onClaim,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    String severityText = 'MEDIUM';
    if (ticket.severity == TicketSeverity.critical) {
      severityText = 'CRITICAL';
    } else if (ticket.severity == TicketSeverity.low) {
      severityText = 'LOW';
    } else {
      severityText = 'HIGH';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFF1F5F9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // bg-slate-50
            borderRadius: BorderRadius.circular(12), // rounded-xl
            border: Border.all(color: const Color(0xFFE2E8F0)), // border-slate-200
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Code & Severity Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.code,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900, // font-mono font-bold
                      fontFamily: 'monospace',
                      color: Color(0xFFBE123C), // text-rose-700
                      letterSpacing: 0.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6), // bg-rose-100
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      severityText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFBE123C), // text-rose-700
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Row 2: Machine Name
              Text(
                ticket.machineName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800, // font-bold text-slate-900
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 3),

              // Row 3: Description (line-clamp-1 text-slate-500)
              Text(
                ticket.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B), // text-slate-500
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
