class TicketModel {
  final String id;
  final String title;
  final String priority;
  final String status;

  TicketModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'status': status,
    };
  }
}
