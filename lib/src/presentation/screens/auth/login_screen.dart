import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              IconButton(
                alignment: Alignment.topRight,
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/welcome'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Sign In",
                      style: AppTypography.headline,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: _emailFocusNode,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        _emailFocusNode.hasFocus
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: "Enter your email",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        _passwordFocusNode.hasFocus
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(
                      Icons.visibility_off,
                      color: AppColors.textSecondary,
                    ),
                    hintText: "Enter your password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot password?",
                    style: AppTypography.captionLink,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don’t have an account?", style: AppTypography.caption),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: Text("Sign up", style: AppTypography.captionLink),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              SignInButton(
                Buttons.Google,
                text: "Sign in with Google",
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
