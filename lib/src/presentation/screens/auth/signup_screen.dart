import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/presentation/bloc/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  DateTime? _selectedDate;
  String _selectedGender = 'true'; // true for male, false for female

  @override
  void initState() {
    super.initState();
    void listener() => setState(() {});
    _usernameFocusNode.addListener(listener);
    _emailFocusNode.addListener(listener);
    _passwordFocusNode.addListener(listener);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateOfBirthController.dispose();

    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format as displayed: MM/DD/YYYY
        _dateOfBirthController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onSignUpPressed(BuildContext context, bool isLoading) {
    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      // Format date as DD/MM/YYYY for API
      String formattedDate = '';
      if (_selectedDate != null) {
        formattedDate =
            '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
      }

      context.read<AuthBloc>().add(
        SignUpRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          email: _emailController.text.trim(),
          gender: _selectedGender,
          birthDate: formattedDate,
        ),
      );
    }
  }

  BoxDecoration _fieldBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is Unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng kiểm tra email.'),
              backgroundColor: Colors.green,
            ),
          );
          context.push(
            '/email-verification',
            extra: _emailController.text.trim(),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => context.pop(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Sign Up",
                                      style: AppTypography.headline,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // --- FIELD 1: EMAIL ---
                              Container(
                                decoration: _fieldBoxDecoration(),
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  style: AppTypography.body,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _fieldInputDecoration(
                                    hintText: "Enter your email",
                                    icon: Icons.email_outlined,
                                    hasFocus: _emailFocusNode.hasFocus,
                                  ),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? "Email is required"
                                              : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- FIELD 2: USERNAME ---
                              Container(
                                decoration: _fieldBoxDecoration(),
                                child: TextFormField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocusNode,
                                  style: AppTypography.body,
                                  decoration: _fieldInputDecoration(
                                    hintText: "Enter your username",
                                    icon: Icons.account_circle_outlined,
                                    hasFocus: _usernameFocusNode.hasFocus,
                                  ),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? "Username is required"
                                              : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- FIELD 3: GENDER ---
                              Container(
                                decoration: _fieldBoxDecoration(),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedGender,
                                  style: AppTypography.body,
                                  decoration: _fieldInputDecoration(
                                    hintText: "Select your gender",
                                    icon: Icons.person_outline,
                                    hasFocus: false,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'true',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'false',
                                      child: Text('Female'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? "Gender is required"
                                              : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- FIELD 4: DATE OF BIRTH ---
                              Container(
                                decoration: _fieldBoxDecoration(),
                                child: TextFormField(
                                  controller: _dateOfBirthController,
                                  style: AppTypography.body,
                                  readOnly: true,
                                  decoration: _fieldInputDecoration(
                                    hintText: "Select your date of birth",
                                    icon: Icons.cake_outlined,
                                    hasFocus: false,
                                  ),
                                  onTap: () => _selectDate(context),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? "Date of birth is required"
                                              : null,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // --- FIELD 4: PASSWORD ---
                              Container(
                                decoration: _fieldBoxDecoration(),
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _isPasswordObscured,
                                  style: AppTypography.body,
                                  decoration: _fieldInputDecoration(
                                    hintText: "Enter your password",
                                    icon: Icons.lock_outline,
                                    hasFocus: _passwordFocusNode.hasFocus,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordObscured =
                                              !_isPasswordObscured;
                                        });
                                      },
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          value!.length < 6
                                              ? "Password must be 6+ chars"
                                              : null,
                                ),
                              ),
                            ],
                          ),

                          // --- BUTTONS ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed:
                                    () => _onSignUpPressed(context, isLoading),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isLoading
                                          ? Colors.grey
                                          : AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  isLoading ? "Signing Up..." : "Sign Up",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: AppTypography.caption,
                                  ),
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: Text(
                                      "Sign in",
                                      style: AppTypography.captionLink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text("OR"),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SignInButton(
                                Buttons.Google,
                                text: "Continue with Google",
                                onPressed: () {
                                  // TODO: Thêm logic Google Sign Up
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _fieldInputDecoration({
    required String hintText,
    required IconData icon,
    bool hasFocus = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor:
          hasFocus ? AppColors.backgroundDark : AppColors.backgroundLight,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
