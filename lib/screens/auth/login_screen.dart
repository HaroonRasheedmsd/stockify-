import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
      _rememberMe,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Invalid Admin Username or Password!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_outlined,
                    size: 54,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to access your inventory portal',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Form Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Username',
                            hint: 'Enter your admin username',
                            prefixIcon: Icons.person_outline,
                            controller: _usernameController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Password',
                            hint: 'Enter your admin password',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            controller: _passwordController,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Password is required';
                              }
                              if (val.length < 5) {
                                return 'Password too short';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Remember me
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? true;
                                    });
                                  },
                                  activeColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remember login details',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Submit
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return CustomButton(
                                text: 'Sign In',
                                icon: Icons.login_outlined,
                                isLoading: auth.isLoading,
                                onPressed: _submit,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Footer credentials tip (extremely helpful for viva evaluation!)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Test Credentials: Use admin / admin123',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.blueGrey[300] : Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
