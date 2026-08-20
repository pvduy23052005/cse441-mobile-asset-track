class MachineFormatters {

  static const Map<String, String> _specKeyMap = {

    'clamping_force': 'Lực kẹp khuôn',
    'clamping_force_ton': 'Lực kẹp (Tấn)',
    'clamping_force_kn': 'Lực kẹp (kN)',
    'clamp_force': 'Lực kẹp khuôn',
    'mold_clamping_force': 'Lực kẹp khuôn',
    'press_force': 'Lực ép tối đa',
    'tonnage': 'Trọng tải ép (Tấn)',
    'force': 'Lực ép',

    'screw_diameter': 'Đường kính trục vít',
    'screw_diameter_mm': 'Đường kính trục vít (mm)',
    'diameter': 'Đường kính',

    'injection_pressure': 'Áp suất phun',
    'injection_pressure_mpa': 'Áp suất phun (MPa)',
    'injection_pressure_bar': 'Áp suất phun (bar)',

    'injection_volume': 'Thể tích phun',
    'injection_volume_cm3': 'Thể tích phun (cm³)',
    'injection_capacity': 'Dung tích phun',

    'injection_rate': 'Tốc độ phun',
    'injection_rate_cm3_s': 'Tốc độ phun (cm³/s)',
    'injection_rate_cm3_sec': 'Tốc độ phun (cm³/s)',
    'injection_rate_cm3s': 'Tốc độ phun (cm³/s)',
    'injection_speed': 'Tốc độ phun',

    'injection_weight': 'Trọng lượng phun',
    'shot_weight': 'Khối lượng ép',
    'shot_size': 'Khối lượng ép một lần',

    'mold_height': 'Chiều cao khuôn',
    'mold_height_min': 'Chiều cao khuôn tối thiểu',
    'mold_height_max': 'Chiều cao khuôn tối đa',
    'mold_thickness': 'Độ dày khuôn',
    'mold_opening_stroke': 'Hành trình mở khuôn',
    'mold_open_stroke': 'Hành trình mở khuôn',
    'open_stroke': 'Hành trình mở khuôn',
    'max_daylight': 'Khoảng mở khuôn tối đa',
    'max_daylight_mm': 'Khoảng mở khuôn tối đa (mm)',
    'daylight': 'Khoảng sáng giữa 2 bàn kẹp',

    'tie_bar_distance': 'Khoảng cách giữa 4 trụ',
    'tie_bar_distance_mm': 'Khoảng cách giữa 4 trụ (mm)',
    'tie_bar_spacing': 'Khoảng cách giữa 4 trụ',
    'tie_bar_spacing_mm': 'Khoảng cách giữa 4 trụ (mm)',
    'tie_bar_space': 'Khoảng cách 4 trụ',
    'tie_bar_space_mm': 'Khoảng cách 4 trụ (mm)',
    'tie_bar_clearance': 'Khoảng lọt lòng 4 trụ',
    'tie_bar_clearance_mm': 'Khoảng lọt lòng 4 trụ (mm)',

    'platen_size': 'Kích thước bàn kẹp',
    'platen_size_mm': 'Kích thước bàn kẹp (mm)',
    'platen_dimensions': 'Kích thước bàn kẹp',
    'platen_dimension': 'Kích thước bàn kẹp',

    'ejector_stroke': 'Hành trình chốt đẩy',
    'ejector_stroke_mm': 'Hành trình chốt đẩy (mm)',
    'ejector_force': 'Lực đẩy phôi',
    'ejector_force_ton': 'Lực đẩy phôi (Tấn)',
    'ejector_force_kn': 'Lực đẩy phôi (kN)',
    'ejector_pins': 'Số chốt đẩy',

    'heater_power': 'Công suất gia nhiệt',
    'heater_power_kw': 'Công suất gia nhiệt (kW)',
    'heating_power': 'Công suất gia nhiệt',
    'heating_power_kw': 'Công suất gia nhiệt (kW)',
    'heating_zones': 'Số vùng gia nhiệt',
    'barrel_heating': 'Gia nhiệt nòng trục vít',
    'hopper_capacity': 'Dung tích phễu liệu',
    'hopper_capacity_l': 'Dung tích phễu liệu (Lít)',
    'hopper_capacity_kg': 'Dung tích phễu liệu (kg)',

    'max_pressure': 'Áp suất tối đa',
    'max_pressure_bar': 'Áp suất tối đa (bar)',
    'max_pressure_mpa': 'Áp suất tối đa (MPa)',
    'working_pressure': 'Áp suất làm việc',
    'operating_pressure': 'Áp suất hoạt động',
    'pressure': 'Áp suất',
    'piston_stroke': 'Hành trình piston',
    'stroke': 'Hành trình piston',
    'air_flow': 'Lưu lượng khí',
    'flow_rate': 'Lưu lượng khí nén',
    'flow': 'Lưu lượng',
    'tank_capacity': 'Dung tích bình chứa',
    'oil_capacity': 'Dung tích dầu thủy lực',
    'oil_tank_capacity': 'Dung tích bình dầu',
    'oil_tank_capacity_l': 'Dung tích bình dầu (Lít)',
    'oil_type': 'Loại dầu bôi trơn',
    'lubricant': 'Dầu bôi trơn',
    'volume': 'Dung tích / Thể tích',

    'power': 'Công suất',
    'motor_power': 'Công suất động cơ',
    'motor_power_kw': 'Công suất động cơ (kW)',
    'pump_motor_power': 'Công suất động cơ bơm',
    'pump_motor_kw': 'Công suất động cơ bơm (kW)',
    'power_kw': 'Công suất (kW)',
    'power_w': 'Công suất (W)',
    'rated_power': 'Công suất định mức',
    'total_power': 'Tổng công suất tiêu thụ',
    'total_power_kw': 'Tổng công suất (kW)',
    'voltage': 'Nguồn điện / Điện áp',
    'operating_voltage': 'Điện áp hoạt động',
    'voltage_v': 'Điện áp (V)',
    'rated_voltage': 'Điện áp định mức',
    'power_supply': 'Nguồn điện cấp',
    'frequency': 'Tần số',
    'frequency_hz': 'Tần số (Hz)',
    'current': 'Dòng điện định mức',

    'spindle_speed': 'Tốc độ trục chính',
    'spindle_speed_rpm': 'Tốc độ trục chính (RPM)',
    'rpm': 'Vòng quay (RPM)',
    'speed': 'Tốc độ hoạt động',
    'max_speed': 'Tốc độ tối đa',
    'spindle_power': 'Công suất trục chính',
    'spindle_taper': 'Côn trục chính',
    'tool_capacity': 'Số lượng dao chứa',
    'tool_count': 'Số lượng dao',
    'tool_change_time': 'Thời gian thay dao',
    'accuracy': 'Độ chính xác gia công',
    'positioning_accuracy': 'Độ chính xác định vị',
    'repeatability': 'Độ lặp lại',
    'axis_travel': 'Hành trình các trục',
    'x_axis_travel': 'Hành trình trục X',
    'y_axis_travel': 'Hành trình trục Y',
    'z_axis_travel': 'Hành trình trục Z',
    'table_size': 'Kích thước bàn máy',
    'table_load': 'Tải trọng bàn máy',
    'controller': 'Hệ điều khiển',
    'cnc_controller': 'Hệ điều khiển CNC',
    'welding_method': 'Phương pháp hàn',
    'robot_arms': 'Số cánh tay Robot',
    'arm_count': 'Số cánh tay Robot',
    'payload': 'Tải trọng cánh tay',
    'reach': 'Tầm với tối đa',
    'duty_cycle': 'Chu kỳ làm việc',
    'cycle_time': 'Thời gian chu kỳ',

    'lifting_capacity': 'Tải trọng nâng',
    'lifting_capacity_ton': 'Tải trọng nâng (Tấn)',
    'load_capacity': 'Tải trọng tối đa',
    'lifting_height': 'Chiều cao nâng tối đa',
    'lifting_height_mm': 'Chiều cao nâng (mm)',
    'fork_length': 'Chiều dài càng nâng',
    'engine': 'Động cơ',
    'engine_model': 'Model động cơ',
    'fuel_type': 'Loại nhiên liệu',
    'battery_capacity': 'Dung lượng ắc quy / pin',

    'temperature': 'Nhiệt độ làm việc',
    'max_temp': 'Nhiệt độ tối đa',
    'temp_range': 'Dải nhiệt độ',
    'cooling_type': 'Hệ thống làm mát',
    'cooling_water': 'Nước làm mát',
    'noise_level': 'Độ ồn hoạt động',

    'manufacturer': 'Nhà sản xuất',
    'brand': 'Thương hiệu / Hãng SX',
    'origin': 'Xuất xứ',
    'country_of_origin': 'Nước sản xuất',
    'year': 'Năm sản xuất',
    'year_manufactured': 'Năm sản xuất',
    'manufacturing_year': 'Năm sản xuất',
    'serial_number': 'Số Serial',
    'serial_no': 'Số Serial',
    'weight': 'Trọng lượng máy',
    'machine_weight': 'Trọng lượng máy',
    'machine_weight_kg': 'Trọng lượng máy (kg)',
    'machine_weight_ton': 'Trọng lượng máy (Tấn)',
    'dimension': 'Kích thước (D x R x C)',
    'dimensions': 'Kích thước máy',
    'dimensions_mm': 'Kích thước (mm)',
    'machine_dimensions': 'Kích thước máy',
    'machine_dimensions_mm': 'Kích thước máy (mm)',
    'length': 'Chiều dài',
    'width': 'Chiều rộng',
    'height': 'Chiều cao',
    'size': 'Kích thước',
    'location': 'Vị trí phân xưởng',
    'area': 'Khu vực lắp đặt',
    'line': 'Dây chuyền sản xuất',
    'warranty_period': 'Thời hạn bảo hành',
    'maintenance_interval': 'Chu kỳ bảo trì định kỳ',
    'last_maintenance': 'Lần bảo dưỡng gần nhất',
    'next_maintenance': 'Mốc bảo trì kế tiếp',
    'installation_date': 'Ngày lắp đặt',
    'commission_date': 'Ngày nghiệm thu bàn giao',
    'notes': 'Ghi chú kỹ thuật',
    'description': 'Mô tả chi tiết',
  };

  static const Map<String, String> _unitMap = {
    'cm3_s': 'cm³/s',
    'cm3_sec': 'cm³/s',
    'cm3s': 'cm³/s',
    'cm3': 'cm³',
    'mm': 'mm',
    'cm': 'cm',
    'm': 'm',
    'm3_min': 'm³/phút',
    'm3_h': 'm³/h',
    'kg': 'kg',
    'ton': 'Tấn',
    'tons': 'Tấn',
    't': 'Tấn',
    'kn': 'kN',
    'mpa': 'MPa',
    'bar': 'bar',
    'psi': 'psi',
    'kw': 'kW',
    'w': 'W',
    'v': 'V',
    'hz': 'Hz',
    'rpm': 'RPM',
    'deg_c': '°C',
    'c': '°C',
    'l': 'Lít',
    'liter': 'Lít',
    'liters': 'Lít',
  };

  static const Map<String, String> _wordTranslations = {
    'tie': 'trụ',
    'bar': 'thanh',
    'bars': 'các trụ',
    'spacing': 'khoảng cách',
    'distance': 'khoảng cách',
    'space': 'khoảng cách',
    'clearance': 'khoảng hở',
    'injection': 'phun',
    'rate': 'tốc độ',
    'speed': 'tốc độ',
    'volume': 'thể tích',
    'capacity': 'dung tích',
    'pressure': 'áp suất',
    'force': 'lực',
    'clamping': 'kẹp',
    'clamp': 'kẹp',
    'mold': 'khuôn',
    'mould': 'khuôn',
    'screw': 'trục vít',
    'diameter': 'đường kính',
    'stroke': 'hành trình',
    'opening': 'mở',
    'height': 'chiều cao',
    'width': 'chiều rộng',
    'length': 'chiều dài',
    'size': 'kích thước',
    'weight': 'trọng lượng',
    'platen': 'bàn kẹp',
    'ejector': 'chốt đẩy',
    'pin': 'chốt',
    'pins': 'các chốt',
    'heating': 'gia nhiệt',
    'heater': 'bộ gia nhiệt',
    'cooling': 'làm mát',
    'cooler': 'bộ làm mát',
    'pump': 'bơm',
    'motor': 'động cơ',
    'oil': 'dầu',
    'tank': 'bình',
    'power': 'công suất',
    'voltage': 'điện áp',
    'current': 'dòng điện',
    'frequency': 'tần số',
    'temperature': 'nhiệt độ',
    'temp': 'nhiệt độ',
    'control': 'điều khiển',
    'controller': 'bộ điều khiển',
    'system': 'hệ thống',
    'machine': 'máy',
    'max': 'tối đa',
    'min': 'tối thiểu',
    'total': 'tổng',
    'rated': 'định mức',
    'operating': 'vận hành',
    'working': 'làm việc',
    'barrel': 'nòng vít',
    'hopper': 'phễu',
    'lubrication': 'bôi trơn',
    'hydraulic': 'thủy lực',
    'pneumatic': 'khí nén',
    'electric': 'điện',
    'cycle': 'chu kỳ',
    'time': 'thời gian',
    'daylight': 'khoảng mở',
  };

  static const Map<String, String> _specValueMap = {
    'active': 'Đang hoạt động',
    'inactive': 'Tạm ngưng',
    'maintenance': 'Đang bảo trì',
    'error': 'Lỗi kỹ thuật',
    'stopped': 'Đã dừng',
    'standard': 'Tiêu chuẩn',
    'hydraulic': 'Thủy lực',
    'pneumatic': 'Khí nén',
    'electric': 'Điện tử',
    'manual': 'Thủ công',
    'automatic': 'Tự động',
    'semi-automatic': 'Bán tự động',
    'diesel': 'Dầu Diesel',
    'gasoline': 'Xăng',
    'electric battery': 'Ắc quy / Pin điện',
    'water cooling': 'Làm mát bằng nước',
    'air cooling': 'Làm mát bằng gió',
    'oil cooling': 'Làm mát bằng dầu',
    'yes': 'Có',
    'no': 'Không',
    'true': 'Có hỗ trợ',
    'false': 'Không',
  };

  static String formatSpecKey(String rawKey) {
    var cleanKey =
        rawKey.trim().toLowerCase().replaceAll(RegExp(r'[\s\-_/]+'), '_');

    if (_specKeyMap.containsKey(cleanKey)) {
      return _specKeyMap[cleanKey]!;
    }

    if (rawKey.contains(' ') ||
        RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
                caseSensitive: false)
            .hasMatch(rawKey)) {
      return rawKey;
    }

    String unitSuffix = '';
    for (final unitEntry in _unitMap.entries) {
      final pattern = '_${unitEntry.key}';
      if (cleanKey.endsWith(pattern)) {
        cleanKey = cleanKey.substring(0, cleanKey.length - pattern.length);
        unitSuffix = ' (${unitEntry.value})';
        break;
      }
    }

    if (_specKeyMap.containsKey(cleanKey)) {
      final translated = _specKeyMap[cleanKey]!;
      return unitSuffix.isNotEmpty && !translated.contains('(')
          ? '$translated$unitSuffix'
          : translated;
    }

    final words = cleanKey.split('_').where((w) => w.isNotEmpty).toList();
    if (words.isNotEmpty) {
      final translatedWords = words.map((w) {
        return _wordTranslations[w] ?? w;
      }).toList();

      String result = translatedWords.join(' ');

      result = result[0].toUpperCase() + result.substring(1);
      return '$result$unitSuffix';
    }

    return rawKey;
  }

  static String formatSpecValue(dynamic rawValue) {
    if (rawValue == null) return 'N/A';
    if (rawValue is bool) return rawValue ? 'Có hỗ trợ' : 'Không';
    if (rawValue is List) {
      return rawValue.map((e) => formatSpecValue(e)).join(', ');
    }
    if (rawValue is Map) {
      return rawValue.entries
          .map((e) => '${formatSpecKey(e.key.toString())}: ${formatSpecValue(e.value)}')
          .join(';\n');
    }

    final str = rawValue.toString().trim();
    final lower = str.toLowerCase();
    if (_specValueMap.containsKey(lower)) {
      return _specValueMap[lower]!;
    }

    return str;
  }

  static String formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }
}
