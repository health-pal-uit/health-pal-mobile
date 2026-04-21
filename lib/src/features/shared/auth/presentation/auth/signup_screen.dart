import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
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
  bool _isExpertMode = false;
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
    // Rebuild UI on focus change to update border/fill colors
    _usernameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
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
            colorScheme: const ColorScheme.light(
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
        _dateOfBirthController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onSignUpPressed(BuildContext context, bool isLoading) {
    if (isLoading) return;

    if (_formKey.currentState!.validate()) {
      String formattedDate = '';
      if (_selectedDate != null) {
        // Format date as DD/MM/YYYY for API
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
              content: Text(
                'Registration successful! Please check your email.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.push(
            '/email-verification',
            extra: {
              'email': _emailController.text.trim(),
              'isExpertMode': _isExpertMode,
            },
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 40),

                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            hintText: "Enter your email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (value) =>
                                    value!.isEmpty ? "Email is required" : null,
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _usernameController,
                            focusNode: _usernameFocusNode,
                            hintText: "Enter your username",
                            icon: Icons.account_circle_outlined,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Username is required"
                                        : null,
                          ),
                          const SizedBox(height: 20),

                          _buildDropdownField(),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _dateOfBirthController,
                            hintText: "Select your date of birth",
                            icon: Icons.cake_outlined,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Date of birth is required"
                                        : null,
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            hintText: "Enter your password",
                            icon: Icons.lock_outline,
                            obscureText: _isPasswordObscured,
                            validator:
                                (value) =>
                                    value!.length < 6
                                        ? "Password must be 6+ chars"
                                        : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        _isPasswordObscured =
                                            !_isPasswordObscured,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          _buildSignUpButton(context, isLoading),
                          const SizedBox(height: 16),

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

                          _buildDivider(),
                          const SizedBox(height: 20),

                          SignInButton(
                            Buttons.Google,
                            text: "Continue with Google",
                            onPressed: () {
                              // TODO: Add Google Sign Up logic
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                          ),

                          const SizedBox(height: 40),

                          //expert registration
                          if (!_isExpertMode) ...[
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              "Are you a healthcare professional?",
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => setState(() => _isExpertMode = true),
                              child: Text(
                                "Register as an Expert",
                                style: AppTypography.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              "Step 1/2: Create your account first.\nYou will upload credentials after verifying your email.",
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  () => setState(() => _isExpertMode = false),
                              child: Text(
                                "Register as a normal user instead",
                                style: AppTypography.captionLink.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isExpertMode) {
              setState(() => _isExpertMode = false);
            } else {
              context.pop();
            }
          },
        ),
        Expanded(
          child: Text(
            _isExpertMode ? "Expert Registration" : "Sign Up",
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final hasFocus = focusNode?.hasFocus ?? false;

    return Container(
      decoration: _fieldBoxDecoration(),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: AppTypography.body,
        validator: validator,
        decoration: InputDecoration(
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
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: _fieldBoxDecoration(),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        style: AppTypography.body,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.backgroundLight,
          prefixIcon: const Icon(Icons.person_outline),
          hintText: "Select your gender",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.textSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'true', child: Text('Male')),
          DropdownMenuItem(value: 'false', child: Text('Female')),
        ],
        onChanged: (value) => setState(() => _selectedGender = value!),
        validator:
            (value) =>
                value == null || value.isEmpty ? "Gender is required" : null,
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
      onPressed: () => _onSignUpPressed(context, isLoading),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? Colors.grey : AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        isLoading ? "Signing Up..." : "Sign Up",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("OR", style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  BoxDecoration _fieldBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
