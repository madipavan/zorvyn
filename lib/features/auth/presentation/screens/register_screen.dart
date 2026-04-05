import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mob/core/di/injector.dart';
import 'package:frontend_mob/core/theme/app_text_styles.dart';
import 'package:frontend_mob/core/widgets/app_button.dart';
import 'package:frontend_mob/core/widgets/app_snackbar.dart';
import 'package:frontend_mob/core/widgets/app_text_field.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend_mob/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthFailedState) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text('Create account', style: AppTextStyles.heading),

                      const SizedBox(height: 8),

                      Text(
                        'Start tracking your finances today',
                        style: AppTextStyles.body,
                      ),

                      const SizedBox(height: 40),

                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outlined,
                        keyboardType: TextInputType.name,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your name';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Enter your password';
                          if (v.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      AppButton(
                        text: 'Create Account',
                        loading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              RegisterRequested(
                                _nameCtrl.text.trim(),
                                _emailCtrl.text.trim(),
                                _passwordCtrl.text,
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.body,
                          ),
                          TextButton(
                            onPressed: () => context.go('/auth/login'),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
