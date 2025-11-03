import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  static const double kDesktopBreakpoint = 640.0;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _userValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'El usuario no puede estar vacío';
    if (v.trim().length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña no puede estar vacía';
    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage( )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    final formWidget = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia sesión para continuar',
            style: TextStyle(color: primary),
          ),
          const SizedBox(height: 24),
          TextFieldApp(
            controller: _userCtrl,
            validator: _userValidator,
            labelText: 'Usuario',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          TextFieldApp(
            controller: _passCtrl,
            obscureText: _obscure,
            validator: _passwordValidator,
            labelText: 'Contraseña',
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility : Icons.visibility_off,
                color: primary,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButtonApp(
            text: 'Entrar',
            icon: Icons.login,
            onPressed: _submit,
            isLoading: _loading,
            maxWidth: 400,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: null,
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: primary),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > kDesktopBreakpoint) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: formWidget,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: formWidget,
              ),
            );
          },
        ),
      ),
    );
  }
}
