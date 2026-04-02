import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/branding.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showLicense = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Branding.primaryColor,
              Branding.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Branding.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Branding.appIcon,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // App Name
                      Text(
                        Branding.appName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Branding.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Version
                      Text(
                        'Version ${Branding.appVersion}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      
                      // Username Field
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person, color: Branding.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Branding.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Branding.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Branding.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Branding.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      
                      // Error Message
                      if (authProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  print('🔐 Attempting login with: ${_usernameController.text.trim()}');
                                  final success = await authProvider.login(
                                    _usernameController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                  print('📊 Login success: $success');
                                  if (success && mounted) {
                                    final user = authProvider.user;
                                    if (user != null) {
                                      print('👤 User role: ${user.role}');
                                      print('👤 Position Level: ${user.positionLevel}');
                                      
                                      if (user.isOperator) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/operator',
                                          arguments: user,
                                        );
                                      } 
                                      else if (user.isFuelman) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/fuelman',
                                          arguments: user,
                                        );
                                      } 
                                      else if (user.isSupervisor) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/supervisor',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isSectionHead) {
                                        print('✅ Navigating to Section Head Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/section_head',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isDepartmentHead) {
                                        print('✅ Navigating to Department Head Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/dept_head',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isDeputyManager) {
                                        print('✅ Navigating to Deputy Manager Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/deputy',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isPJO) {
                                        print('✅ Navigating to PJO Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/pjo',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isDireksi) {
                                        print('✅ Navigating to Direksi Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/direksi',
                                          arguments: user,
                                        );
                                      }
                                      else if (user.isAdmin) {
                                        print('✅ Navigating to Admin Dashboard');
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/admin',
                                          arguments: user,
                                        );
                                      } 
                                      else {
                                        print('⚠️ Unknown role: ${user.role}');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Unknown role: ${user.role}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Branding.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Demo Accounts Info - Diperbarui dengan semua level
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🔑 DEMO ACCOUNT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Operator: opr001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Fuelman: fml001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Supervisor: spv001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Section Head: sh001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Department Head: dh001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Deputy Manager: dep001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'PJO: pjo001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Direksi: dir001 / password123',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Admin: admin / admin123',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Personal Mark & Copyright
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        Branding.copyrightText,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      
                      // Developer Name (Personal Mark)
                      Text(
                        'Developed by: ${Branding.developerName}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Branding.primaryColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      
                      // License Link
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showLicense = !_showLicense;
                          });
                        },
                        child: Text(
                          'License & Terms',
                          style: TextStyle(
                            fontSize: 10,
                            color: Branding.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      
                      // License Text (Expandable)
                      if (_showLicense)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              Branding.licenseText,
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}