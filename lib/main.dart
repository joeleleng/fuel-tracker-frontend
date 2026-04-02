import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'providers/auth_provider.dart';
import 'services/session_service.dart';
import 'screens/login_screen.dart';
import 'screens/license_expired_screen.dart';
import 'screens/operator_dashboard.dart';
import 'screens/fuelman_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/section_head_dashboard.dart';
import 'screens/dept_head_dashboard.dart';
import 'screens/deputy_dashboard.dart';
import 'screens/pjo_dashboard.dart';
import 'screens/direksi_dashboard.dart';
import 'models/user.dart';
import 'models/fuel_entry_hive.dart';
import 'config/branding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize Supabase
  await supabase.Supabase.initialize(
    url: 'https://oqfyvzpfyqdmnxvbzddo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9xZnl2enBmeXFkbW54dmJ6ZGRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NTkxNzYsImV4cCI6MjA5MDUzNTE3Nn0.Kj-lc9INxC7ECCMZcZAc80xrGR0SLYi1lTctM76dGT8',
  );
  
  // Initialize Hive for web compatibility
  await Hive.initFlutter();
  
  // Register Hive adapter for FuelEntryHive
  Hive.registerAdapter(FuelEntryHiveAdapter());
  
  // Open box to ensure it's ready
  await Hive.openBox<FuelEntryHive>('fuel_entries');
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AuthProvider _authProvider;
  bool _isShowingWarning = false;
  Timer? _warningCheckTimer;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize auth provider
    _authProvider = AuthProvider();
    
    // Setup logout callback untuk navigasi
    _authProvider.onLogoutCallback = () {
      _navigateToLogin();
    };
    
    // Start periodic check for session warning
    _startWarningCheck();
  }

  @override
  void dispose() {
    _warningCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _navigateToLogin() {
    if (mounted) {
      // Pop semua route dan navigasi ke login
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      navigatorKey.currentState?.pushReplacementNamed('/login');
    }
  }

  void _startWarningCheck() {
    _warningCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _authProvider.isAuthenticated) {
        final remaining = _authProvider.sessionService.remainingSeconds;
        
        // Debug log setiap 5 detik
        if (remaining % 5 == 0 || remaining <= 5) {
          print('⏱️ Session remaining: $remaining seconds');
        }
        
        // Check if session expired
        if (remaining <= 0) {
          print('💀 Session expired! Logging out...');
          timer.cancel();
          _authProvider.logout(isAutoLogout: true);
          _navigateToLogin();
        }
        // Show warning at 30 seconds or less
        else if (remaining <= 30 && remaining > 0 && !_isShowingWarning) {
          print('⚠️ Showing session warning at $remaining seconds');
          _showSessionWarning(context);
        }
        // Reset warning flag if remaining > 30 (user extended session)
        else if (remaining > 30 && _isShowingWarning) {
          _isShowingWarning = false;
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause session saat app di background
    if (state == AppLifecycleState.paused) {
      _authProvider.pauseSession();
    }
    // Resume session saat app kembali ke foreground
    else if (state == AppLifecycleState.resumed) {
      _authProvider.resumeSession();
      // Reset warning flag saat kembali
      _isShowingWarning = false;
    }
  }

  /// Global gesture detector untuk mendeteksi aktivitas user
  Widget _buildWithSessionTracker(Widget child) {
    return GestureDetector(
      onTap: () {
        _authProvider.resetSessionActivity();
      },
      onLongPress: () {
        _authProvider.resetSessionActivity();
      },
      onPanDown: (_) {
        _authProvider.resetSessionActivity();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _authProvider.resetSessionActivity();
          return false;
        },
        child: child,
      ),
    );
  }

  /// Show session warning dialog
  void _showSessionWarning(BuildContext context) {
    if (_isShowingWarning) return;
    _isShowingWarning = true;
    
    print('🔔 Opening session warning dialog');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SessionWarningDialog(
        sessionService: _authProvider.sessionService,
        onExtend: () {
          print('🔄 User extended session');
          _authProvider.resetSessionActivity();
          _isShowingWarning = false;
        },
      ),
    ).then((_) {
      _isShowingWarning = false;
    });
  }

  /// Get dashboard screen based on user role
  Widget _getDashboardScreen(User user) {
    print('👤 Getting dashboard for role: ${user.role}');
    switch (user.role.toLowerCase()) {
      case 'operator':
        return OperatorDashboard(user: user);
      case 'fuelman':
        return FuelmanDashboard(user: user);
      case 'supervisor':
        return SupervisorDashboard(user: user);
      case 'section_head':
        return SectionHeadDashboard(user: user);
      case 'dept_head':
        return DeptHeadDashboard(user: user);
      case 'deputy':
        return DeputyDashboard(user: user);
      case 'pjo':
        return PJODashboard(user: user);
      case 'direksi':
        return DireksiDashboard(user: user);
      case 'admin':
        return AdminDashboard(user: user);
      case 'super_admin':
        print('👑 Redirecting to Super Admin Dashboard');
        return SuperAdminDashboard(user: user);
      default:
        print('⚠️ Unknown role: ${user.role}, defaulting to Operator');
        return OperatorDashboard(user: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: _authProvider,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: Branding.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: Branding.primaryColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            initialRoute: authProvider.isAuthenticated ? '/dashboard' : '/login',
            onGenerateRoute: (settings) {
              // Dashboard route based on user role
              if (settings.name == '/dashboard') {
                if (authProvider.user != null) {
                  return MaterialPageRoute(
                    builder: (context) => _getDashboardScreen(authProvider.user!),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              }
              
              // Login route
              if (settings.name == '/login') {
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              }
              
              // License expired route
              if (settings.name == '/license-expired') {
                return MaterialPageRoute(
                  builder: (context) => const LicenseExpiredScreen(),
                );
              }
              
              // Test route untuk akses langsung license expired (tanpa login)
              if (settings.name == '/test-license') {
                return MaterialPageRoute(
                  builder: (context) => const LicenseExpiredScreen(),
                );
              }
              
              // Super Admin route
              if (settings.name == '/superadmin') {
                if (authProvider.user != null && authProvider.user!.role == 'super_admin') {
                  return MaterialPageRoute(
                    builder: (context) => SuperAdminDashboard(user: authProvider.user!),
                  );
                }
                return MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                );
              }
              
              // Legacy routes for compatibility
              if (settings.name == '/operator' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => OperatorDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/fuelman' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => FuelmanDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/supervisor' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => SupervisorDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/section_head' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => SectionHeadDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/dept_head' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => DeptHeadDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/deputy' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => DeputyDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/pjo' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => PJODashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/direksi' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => DireksiDashboard(user: settings.arguments as User),
                );
              }
              if (settings.name == '/admin' && settings.arguments is User) {
                return MaterialPageRoute(
                  builder: (context) => AdminDashboard(user: settings.arguments as User),
                );
              }
              
              // Fallback
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
            builder: (context, child) {
              return _buildWithSessionTracker(child ?? const SizedBox.shrink());
            },
          );
        },
      ),
    );
  }
}

/// Separate widget for session warning dialog with countdown
class _SessionWarningDialog extends StatefulWidget {
  final SessionService sessionService;
  final VoidCallback onExtend;

  const _SessionWarningDialog({
    required this.sessionService,
    required this.onExtend,
  });

  @override
  State<_SessionWarningDialog> createState() => _SessionWarningDialogState();
}

class _SessionWarningDialogState extends State<_SessionWarningDialog> {
  late Timer _timer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.sessionService.remainingSeconds;
    print('⚠️ Warning dialog opened - remaining: $_remainingSeconds seconds');
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final currentRemaining = widget.sessionService.remainingSeconds;
        setState(() {
          _remainingSeconds = currentRemaining;
        });
        
        // Debug log setiap detik
        if (_remainingSeconds <= 10) {
          print('⏰ Dialog countdown: $_remainingSeconds seconds');
        }
        
        // Close dialog if session extended (remaining > 30)
        if (_remainingSeconds > 30) {
          print('✅ Session extended, closing warning dialog');
          _timer.cancel();
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
        // Auto close if session expired
        else if (_remainingSeconds <= 0) {
          print('💀 Session expired, closing warning dialog');
          _timer.cancel();
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Session Akan Berakhir'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Session Anda akan berakhir dalam:'),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _remainingSeconds <= 10 ? Colors.red : Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tekan "Lanjutkan Session" untuk memperpanjang session.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onExtend();
            _timer.cancel();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Lanjutkan Session'),
        ),
      ],
    );
  }
}