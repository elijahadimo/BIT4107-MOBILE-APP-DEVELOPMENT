import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/financial_dashboard.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/branch_management_screen.dart';
import '../screens/admin/complaint_management_screen.dart';
import '../screens/admin/cms_edit_screen.dart';
import '../screens/admin/chat_list_screen.dart';
import '../screens/agent/agent_dashboard.dart';
import '../screens/agent/create_shipment_screen.dart';
import '../screens/agent/load_truck_screen.dart';
import '../screens/agent/shipment_detail_screen.dart';
import '../screens/agent/qr_scanner_screen.dart';
import '../screens/driver/driver_dashboard.dart';
import '../screens/driver/report_incident_screen.dart';
import '../screens/asst_driver/asst_driver_dashboard.dart';
import '../screens/asst_driver/delivery_screen.dart';
import '../screens/customer/landing_page.dart';
import '../screens/common/business_card_screen.dart';
import '../models/user.dart';
import '../models/shipment.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) => GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final auth = authProvider;
      final loggingIn = state.matchedLocation == '/login';

      if (!auth.isAuthenticated) {
        // If not authenticated and not on landing or login, redirect to landing
        if (state.matchedLocation != '/' && !loggingIn) {
          return '/';
        }
        return null;
      }

      // If authenticated and trying to go to login or landing, go to dashboard
      if (loggingIn || state.matchedLocation == '/') {
        switch (auth.user!.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.agent:
            return '/agent';
          case UserRole.driver:
            return '/driver';
          case UserRole.asstDriver:
            return '/asst-driver';
          case UserRole.customer:
            return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/business-card',
        builder: (context, state) => const BusinessCardScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'financial',
            builder: (context, state) => const FinancialDashboard(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'branches',
            builder: (context, state) => const BranchManagementScreen(),
          ),
          GoRoute(
            path: 'incidents',
            builder: (context, state) => const ComplaintManagementScreen(),
          ),
          GoRoute(
            path: 'cms',
            builder: (context, state) => const CmsEditScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/agent',
        builder: (context, state) => const AgentDashboard(),
        routes: [
          GoRoute(
            path: 'create-shipment',
            builder: (context, state) => const CreateShipmentScreen(),
          ),
          GoRoute(
            path: 'load-truck',
            builder: (context, state) => const LoadTruckScreen(),
          ),
          GoRoute(
            path: 'shipment-detail',
            builder: (context, state) {
              final shipment = state.extra as Shipment;
              return ShipmentDetailScreen(shipment: shipment);
            },
          ),
          GoRoute(
            path: 'scanner',
            builder: (context, state) {
              final mode = state.extra as ScannerMode;
              return QrScannerScreen(mode: mode);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/driver',
        builder: (context, state) => const DriverDashboard(),
        routes: [
          GoRoute(
            path: 'report-incident',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ReportIncidentScreen(
                tripId: extra?['tripId'],
                shipmentId: extra?['shipmentId'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/asst-driver',
        builder: (context, state) => const AsstDriverDashboard(),
        routes: [
          GoRoute(
            path: 'delivery',
            builder: (context, state) {
              final shipment = state.extra as Shipment;
              return DeliveryScreen(shipment: shipment);
            },
          ),
        ],
      ),
    ],
  );
}
