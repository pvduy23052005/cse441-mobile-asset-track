class MachineModel {
  final String id;
  final String name;
  final String code;
  final String status;

  MachineModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'status': status,
    };
  }
}
