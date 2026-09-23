// Register screen for KhedmaLink Flutter app
// Handles user registration with email, password, and optional fields
// Features modern UI with gradient background, glassmorphism, and smooth animations

import 'package:flutter/material.dart';
import 'package:khedmalink/core/services/auth_service.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Register screen widget with modern professional design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the terms and conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Attempting registration for: ${_emailController.text}');

      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      AppLogger.info('Registration successful');

      if (mounted) {
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Please login.'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      AppLogger.error('Registration failed: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.grey900,
                    AppTheme.grey800,
                    AppTheme.secondaryDark.withValues(alpha: 0.3),
                  ]
                : [
                    AppTheme.secondaryColor.withValues(alpha: 0.05),
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    AppTheme.accentColor.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Modern logo section with gradient
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppTheme.buttonShadow,
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // App name with modern typography
                        Text(
                          'Create Account',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Tagline with subtle styling
                        Text(
                          'Join KhedmaLink today',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Modern error message with glassmorphism
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.errorColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppTheme.errorColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Full name field
                        TextFormField(
                          controller: _fullNameController,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Full Name (Optional)',
                            hintText: 'Enter your full name',
                            prefixIcon: const Icon(Icons.person_outlined),
                            filled: true,
                            fillColor: isDark ? AppTheme.grey800 : Colors.white,
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: isDark ? AppTheme.grey800 : Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Phone field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Phone (Optional)',
                            hintText: 'Enter your phone number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            filled: true,
                            fillColor: isDark ? AppTheme.grey800 : Colors.white,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < AppConfig.minPhoneLength) {
                                return 'Phone number must be at least ${AppConfig.minPhoneLength} digits';
                              }
                              if (value.length > AppConfig.maxPhoneLength) {
                                return 'Phone number must not exceed ${AppConfig.maxPhoneLength} digits';
                              }
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: isDark ? AppTheme.grey800 : Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < AppConfig.minPasswordLength) {
                              return 'Password must be at least ${AppConfig.minPasswordLength} characters';
                            }
                            if (value.length > AppConfig.maxPasswordLength) {
                              return 'Password must not exceed ${AppConfig.maxPasswordLength} characters';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: isDark ? AppTheme.grey800 : Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Modern terms and conditions checkbox
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppTheme.grey800.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                fillColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppTheme.secondaryColor;
                                  }
                                  return theme.colorScheme.outline;
                                }),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  child: Text(
                                    'I agree to the terms and conditions',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Modern gradient register button
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.buttonShadow,
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Modern login link with subtle styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
