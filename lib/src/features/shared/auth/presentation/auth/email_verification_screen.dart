import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';

class EmailVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EmailVerificationScreen({super.key, required this.data});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late String email;
  late bool isExpertMode;

  late Timer _resendTimer;
  int _countdown = 60;
  bool _canResend = false;

  late Timer _pollTimer;

  @override
  void initState() {
    super.initState();
    email = widget.data['email'] ?? '';
    isExpertMode = widget.data['isExpertMode'] ?? false;

    _startResendTimer();
    _startPolling();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    _pollTimer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _countdown = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      context.read<AuthBloc>().add(CheckVerificationStatus(email));
    });
  }

  void _onResendEmailPressed() {
    if (_canResend) {
      setState(() {
        _startResendTimer();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lại email xác nhận.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        final messenger = ScaffoldMessenger.of(context);
        final router = GoRouter.of(context);

        if (state is VerificationSuccess) {
          _pollTimer.cancel();
          _resendTimer.cancel();

          if (!mounted) return;

          // ✅ Route to appropriate login screen
          if (isExpertMode) {
            router.go('/expert/login');
          } else {
            router.go('/login');
          }
        }

        if (state is AuthFailure) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                  size: 100,
                ),
                const SizedBox(height: 32),
                Text(
                  "Check Your Email",
                  textAlign: TextAlign.center,
                  style: AppTypography.headline,
                ),
                const SizedBox(height: 16),
                Text(
                  "We've sent a confirmation link to:\n$email",
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                _buildResendButton(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Back to Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    if (_canResend) {
      return ElevatedButton(
        onPressed: _onResendEmailPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          "Resend Email",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    } else {
      return Text(
        "Resend available in $_countdown s",
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      );
    }
  }
}
