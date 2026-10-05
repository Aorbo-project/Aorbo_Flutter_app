import 'package:flutter/widgets.dart';

/// Tells screens when they are covered / uncovered by another route.
/// DashboardMain uses it to open a shared trek link or a notification tap
/// only when it is on top again (scan E6), never over a booking in progress.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
