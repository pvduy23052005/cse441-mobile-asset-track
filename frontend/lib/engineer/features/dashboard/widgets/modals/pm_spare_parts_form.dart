import 'package:flutter/material.dart';
import 'pm_checklist_modal.dart';

class PMSparePartsForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final List<PMSparePartData> spareParts;
  final VoidCallback onAddSparePart;

  const PMSparePartsForm({
    super.key,
    required this.nameController,
    required this.qtyController,
    required this.priceController,
    required this.spareParts,
    required this.onAddSparePart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF0284C7)),
                SizedBox(width: 6),
                Text(
                  'KHAI BÁO LINH KIỆN / VẬT TƯ THAY THẾ:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
            Text(
              'Duyệt > 2.0Tr',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        TextField(
          controller: nameController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Tên linh kiện (VD: Vòng bi 7014C)',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'SL',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Đơn giá (VND)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAddSparePart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Thêm',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (spareParts.isNotEmpty)
          ...spareParts.map(
            (sp) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sp.name,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                        '${sp.quantity} cái x ${sp.unitPrice.toStringAsFixed(0)}đ = ${sp.totalCost.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                            fontSize: 10, fontFamily: 'monospace', color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: sp.requiresApproval
                          ? const Color(0xFFFFE4E6)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sp.requiresApproval ? '⚠️ Cần QĐ Duyệt' : '✓ Tự động ghi nhận',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: sp.requiresApproval
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
