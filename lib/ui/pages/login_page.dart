import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/providers/auth_provider.dart'; // Asegúrate de importar el provider correcto
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/services/biometric_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Claves y Controladores
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Estado Local
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _canCheckBiometrics = false;
  bool _hasStoredCredentials = false;

  final _biometricService = BiometricService();

  // Constante de diseño
  static const double kDesktopBreakpoint = 640.0;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkStoredCredentials();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await _biometricService.checkBiometrics();
    if (mounted) setState(() => _canCheckBiometrics = canCheck);
  }

  Future<void> _checkStoredCredentials() async {
    final creds = await ref.read(authServiceProvider).getCredentials();
    if (mounted && creds != null) {
      setState(() {
        _hasStoredCredentials = true;
        // Opcional: Pre-llenar usuario si se desea
        // _userCtrl.text = creds['user_ci']!;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _submit() async {
    // 1. Validar formulario
    if (!_formKey.currentState!.validate()) return;

    _performLogin(_userCtrl.text.trim(), _passCtrl.text);
  }

  Future<void> _performLogin(String user, String pass) async {
    // 2. Ocultar teclado
    FocusScope.of(context).unfocus();

    // 3. Activar estado de carga
    setState(() => _isLoading = true);

    try {
      // 4. Llamar al Provider
      // Usamos ref.read porque es un evento puntual (tap), no una escucha activa
      final success = await ref.read(authProvider.notifier).login(user, pass);

      final userPermissions = ref.watch(currentUserPermissionsProvider);
      final hasAccessSales = userPermissions.can(AppPermissions.createSale);
      final hasAccessPurchases = userPermissions.can(
        AppPermissions.createPurchase,
      );
      final hasAccessProducts = userPermissions.can(
        AppPermissions.readProducts,
      );
      final hasAccessReports = userPermissions.can(AppPermissions.readReports);

      // 5. Verificar si el widget sigue montado antes de usar 'context'
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        // Guardar o Borrar credenciales según "Recuérdame"
        final authService = ref.read(authServiceProvider);
        if (_rememberMe) {
          await authService.saveCredentials(user, pass);
        } else {
          await authService.clearCredentials();
        }

        // ÉXITO: Navegar al Home y reemplazar la ruta de login para que no puedan volver atrás
        if (hasAccessSales) {
          Navigator.pushReplacementNamed(context, AppRoutes.sales);
        } else if (hasAccessPurchases) {
          Navigator.pushReplacementNamed(context, AppRoutes.purchase);
        } else if (hasAccessReports) {
          Navigator.pushReplacementNamed(context, AppRoutes.reportDashboard);
        } else if (hasAccessProducts) {
          Navigator.pushReplacementNamed(context, AppRoutes.inventory);
        }
      } else {
        // ERROR: Mostrar feedback
        _showErrorSnackBar('Credenciales incorrectas o error de conexión.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Ocurrió un error inesperado: $e');
    }
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      final creds = await ref.read(authServiceProvider).getCredentials();
      if (creds != null) {
        setState(() => _isLoading = true);
        await _performLogin(creds['user_ci']!, creds['password']!);
      } else {
        _showErrorSnackBar('No hay credenciales guardadas.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder decide si mostrar vista Móvil o Escritorio
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo limpio
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Diseño Escritorio / Tablet
            if (constraints.maxWidth > kDesktopBreakpoint) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Diseño Móvil
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: _buildLoginForm(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye el contenido del formulario.
  /// Se extrae aquí para reutilizarlo en ambos layouts y limpiar el build().
  Widget _buildLoginForm() {
    final primaryColor = AppColors.primary;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Logo / Ícono
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.lock_person_rounded,
              color: primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Títulos
          Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia sesión para gestionar tu inventario',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 32),

          // 3. Inputs
          TextFieldApp(
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            controller: _userCtrl,
            labelText: 'Usuario',
            prefixIcon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu usuario';
              if (v.trim().length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),

          TextFieldApp(
            textInputAction: TextInputAction.done,

            // 4. Al dar Enter aquí, ejecutamos el Submit directamente
            onFieldSubmitted: (_) => _submit(),
            controller: _passCtrl,
            labelText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            maxLines: 1,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          // 3.5 Remember Me & Biometrics toggle
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
              ),
              const Text('Recuérdame'),
              const Spacer(),
              // Mostrar botón biométrico si es posible usarlo y hay algo guardado
              if (_canCheckBiometrics && _hasStoredCredentials)
                IconButton(
                  icon: Icon(Icons.fingerprint, size: 36, color: primaryColor),
                  tooltip: 'Ingresar con Biometría',
                  onPressed: _isLoading ? null : _loginWithBiometrics,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // 5. Botón de Acción
          PrimaryButtonApp(
            text: 'INGRESAR',
            icon: Icons.login,
            isLoading: _isLoading,
            onPressed: _submit,
            maxWidth: double.infinity, // Ocupa todo el ancho disponible
          ),
        ],
      ),
    );
  }
}
