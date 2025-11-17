import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Timer _resendTimer;
  int _countdown = 60;
  bool _canResend = false;

  late Timer _pollTimer;

  @override
  void initState() {
    super.initState();
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
      context.read<AuthBloc>().add(CheckVerificationStatus(widget.email));
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
      listener: (context, state) {
        if (state is VerificationSuccess) {
          _pollTimer.cancel();
          _resendTimer.cancel();
          context.go('/login');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.message}')));
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
                  "We've sent a confirmation link to:\n${widget.email}",
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
