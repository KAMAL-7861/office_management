import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // ── Design tokens ──────────────────────────────────────────
  static const _teal = Color(0xFF2EDBB8);
  static const _tealDark = Color(0xFF1BC5A0);
  static const _cardBg = Colors.transparent;
  static const _cardBorder = Color(0xFF213324);
  static const _fieldLine = Color(0xFF2B3D2D);
  static const _labelGrey = Color(0xFF7D9080);
  static const _subtitleGrey = Color(0xFF8A9E8C);
  static const _buttonText = Color(0xFF0A1A0C);
  // ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        // ── Card ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _cardBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color:
                                    const Color(0xFF1E4D28).withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, -4),
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
                                  "Welcome\nBack",
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
                                  'Sign in to your workspace.',
                                  style: TextStyle(
                                    color: _subtitleGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 36),

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
                                const SizedBox(height: 26),

                                // ── Password ────────────────
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Enter your password'
                                          : null,
                                  decoration: _field(
                                    'Password',
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _labelGrey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 44),

                                // ── Log In Button ────────────
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
                                                    color: _teal
                                                        .withOpacity(0.28),
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
                                                          .add(LoginRequested(
                                                            _emailController
                                                                .text
                                                                .trim(),
                                                            _passwordController
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
                                                      'Log In',
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
                        ),
                        const SizedBox(height: 26),

                        // ── Bottom link ────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?  ",
                              style: TextStyle(
                                color: _subtitleGrey,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
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
