import 'package:flutter/material.dart';

class SymptomCategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<String> symptoms;

  const SymptomCategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.symptoms,
  });
}

const List<SymptomCategoryModel> defaultSymptomCategories = [
  SymptomCategoryModel(
    id: 'mechanical',
    title: 'Cơ Khí & Truyền Động',
    icon: Icons.settings_suggest_rounded,
    color: Color(0xFF2563EB),
    symptoms: [
      'Kẹt băng chuyền / phôi',
      'Phát tiếng ồn / Rung lắc mạnh',
      'Lệch trục / Trượt dây curoa',
      'Gãy / Mòn dao cắt & chi tiết',
      'Rơ lỏng ổ bi / Khớp nối',
    ],
  ),
  SymptomCategoryModel(
    id: 'electrical',
    title: 'Điện & Tự Động Hóa',
    icon: Icons.bolt_rounded,
    color: Color(0xFFD97706),
    symptoms: [
      'Mất nguồn / Lỗi mạch điện',
      'Lỗi cảm biến / Sensor',
      'Màn hình HMI / PLC báo lỗi',
      'Nhảy CB / Cháy cầu chì',
      'Mất tín hiệu điều khiển',
    ],
  ),
  SymptomCategoryModel(
    id: 'thermal_hydraulic',
    title: 'Nhiệt & Thủy Lực / Khí Nén',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFEA580C),
    symptoms: [
      'Động cơ quá nhiệt (>80°C)',
      'Rò rỉ dầu / nhớt thủy lực',
      'Tụt áp suất khí nén',
      'Hỏng van điều áp / Xi-lanh',
      'Nhiệt độ dầu thủy lực cao',
    ],
  ),
  SymptomCategoryModel(
    id: 'safety_operations',
    title: 'An Toàn & Vận Hành',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFDC2626),
    symptoms: [
      'Dừng khẩn cấp (E-Stop)',
      'Kẹt cửa an toàn / Cảm biến quang',
      'Báo động quá tải động cơ',
      'Mùi khét / Bốc khói',
    ],
  ),
];
