import 'package:flutter_riverpod/flutter_riverpod.dart';

final operatorDashboardPageProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
);

const int operatorDashboardItemsPerPage = 3;

final operatorTicketDashboardPageProvider = StateProvider.autoDispose<int>(
  (ref) => 0,
);

const int operatorTicketDashboardItemsPerPage = 3;
