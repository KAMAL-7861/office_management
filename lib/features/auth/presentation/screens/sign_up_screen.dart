import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user_entity.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.employee;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  // ── Design tokens ──────────────────────────────────────────
  static const _teal = Color(0xFF2EDBB8);
  static const _tealDark = Color(0xFF1BC5A0);
  static const _cardBorder = Color(0xFF2EDBB8); // teal for glass rim
  static const _fieldLine = Color(0xFF2B3D2D);
  static const _labelGrey = Color(0xFF7D9080);
  static const _subtitleGrey = Color(0xFF8A9E8C);
  static const _buttonText = Color(0xFF0A1A0C);
  // ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nameController.dispose();
    _organizationNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  InputDecoration _field(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _labelGrey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffix,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: _fieldLine),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _fieldLine),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _teal, width: 1.5),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: false,
      contentPadding: const EdgeInsets.only(bottom: 10, top: 6),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _labelGrey,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F09),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Base gradient ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0E2011),
                  Color(0xFF060C07),
                  Color(0xFF0B190D),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // ── Top radial shine ───────────────────────────────
          Positioned(
            top: -80,
            left: -60,
            right: -60,
            height: 420,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    const Color(0xFF1E4D28).withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Bottom accent glow ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF162B18).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App title
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Text(
                    'Smart Office',
                    style: TextStyle(
                      color: _teal,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                    child: Column(
                      children: [
                        // ── Glassy Card ───────────────────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF0F2214).withOpacity(0.72),
                                const Color(0xFF081209).withOpacity(0.82),
                                const Color(0xFF0D1C10).withOpacity(0.75),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _cardBorder.withOpacity(0.22),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 36,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: const Color(0xFF2EDBB8).withOpacity(0.06),
                                blurRadius: 28,
                                spreadRadius: 1,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Heading
                                const Text(
                                  "Let's Get\nStarted",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Join your workspace today.',
                                  style: TextStyle(
                                    color: _subtitleGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // ── Name ────────────────────
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter your name'
                                          : null,
                                  decoration: _field('Name'),
                                ),
                                const SizedBox(height: 22),

                                // ── Invite Code / Org Name ──
                                if (_selectedRole == UserRole.employee)
                                  TextFormField(
                                    controller: _inviteCodeController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter the invite code'
                                            : null,
                                    decoration: _field('Invite Code'),
                                  )
                                else
                                  TextFormField(
                                    controller: _organizationNameController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Enter organization name'
                                            : null,
                                    decoration: _field('Organization Name'),
                                  ),
                                const SizedBox(height: 22),

                                // ── Email ───────────────────
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter your email'
                                          : null,
                                  decoration: _field('Email'),
                                ),
                                const SizedBox(height: 22),

                                // ── Create Password ─────────
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter a password';
                                    }
                                    if (v.length < 6) {
                                      return 'Min. 6 characters';
                                    }
                                    return null;
                                  },
                                  decoration: _field(
                                    'Create Password',
                                    suffix: _eyeButton(_obscurePassword, () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // ── Repeat Password ─────────
                                TextFormField(
                                  controller: _repeatPasswordController,
                                  obscureText: _obscureRepeatPassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Repeat your password';
                                    }
                                    if (v != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  decoration: _field(
                                    'Repeat Password',
                                    suffix:
                                        _eyeButton(_obscureRepeatPassword, () {
                                      setState(() {
                                        _obscureRepeatPassword =
                                            !_obscureRepeatPassword;
                                      });
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // ── Role Dropdown ────────────
                                DropdownButtonFormField<UserRole>(
                                  value: _selectedRole,
                                  dropdownColor: const Color(0xFF1A2B1C),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _labelGrey,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: _field('Role'),
                                  borderRadius: BorderRadius.circular(14),
                                  items: UserRole.values.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role.name[0].toUpperCase() +
                                            role.name.substring(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedRole = value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 36),

                                // ── Sign Up Button ───────────
                                BlocConsumer<AuthBloc, AuthState>(
                                  listener: (context, state) {
                                    if (state is AuthError) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: Colors.white,
                                                  size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                  child: Text(state.message)),
                                            ],
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    } else if (state is Authenticated) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isLoading
                                                ? [
                                                    _tealDark.withOpacity(0.45),
                                                    _teal.withOpacity(0.45),
                                                  ]
                                                : [_tealDark, _teal],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: isLoading
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    color:
                                                        _teal.withOpacity(0.28),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            splashColor:
                                                Colors.white.withOpacity(0.08),
                                            onTap: isLoading
                                                ? null
                                                : () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      context
                                                          .read<AuthBloc>()
                                                          .add(SignUpRequested(
                                                            email:
                                                                _emailController
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                _passwordController
                                                                    .text
                                                                    .trim(),
                                                            name:
                                                                _nameController
                                                                    .text
                                                                    .trim(),
                                                            role: _selectedRole,
                                                            organizationName:
                                                                _organizationNameController
                                                                    .text
                                                                    .trim(),
                                                            inviteCode:
                                                                _inviteCodeController
                                                                    .text
                                                                    .trim(),
                                                          ));
                                                    }
                                                  },
                                            child: Center(
                                              child: isLoading
                                                  ? SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                          _buttonText,
                                                        ),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Sign up',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _buttonText,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          ),   // Container
                          ),   // BackdropFilter
                        ),     // ClipRRect
                        const SizedBox(height: 26),


                        // ── Bottom link ────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already a Member?  ',
                              style: TextStyle(
                                color: _subtitleGrey,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: _teal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
