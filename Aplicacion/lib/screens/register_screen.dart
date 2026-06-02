import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Cumplimiento de CA3
  bool _passwordVisible = false;
  bool _isSimulating = false;

//CA3
  void _register() async {
  if (_formKey.currentState!.validate()) {
    // 🔄 NUEVO: Activar simulación de carga
    setState(() => _isSimulating = true);
    
    // 🔄 NUEVO: Simular 2 segundos de procesamiento
    await Future.delayed(const Duration(seconds: 2));
    
    // 🔄 NUEVO: Desactivar simulación
    setState(() => _isSimulating = false);
    
    // Aquí continúa con el registro real
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _phoneController.text.isEmpty ? null : _phoneController.text,
    );

    if (!mounted) return;

    if (error == null) {
      _showVerificationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
  // 🔐 NUEVO: Metodo para envio de validacion de correo
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No permitir cerrar tocando fuera
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Verifica tu correo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Te hemos enviado un enlace de verificación a tu correo electrónico.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              _emailController.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Por favor, verifica tu cuenta antes de iniciar sesión.',
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a LoginScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Logo con gradiente
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.person_add,
                        size: 48,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Únete a nuestra comunidad segura',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Formulario con card
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                      children: [
                        AuthTextField(
                label: 'Nombre completo',
                icon: Icons.person,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              AuthTextField(
                label: 'Correo electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // validación de contraseña (CA2)
              AuthTextField(
                label: 'Contraseña',
                icon: Icons.lock,
                obscureText: !_passwordVisible,  // MODIFICADO: usa la variable
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  // MODIFICADO: RegExp para contraseña segura
                  final passwordRegex = RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$'
                  );
                  if (!passwordRegex.hasMatch(value)) {
                    return 'Debe tener: 8+ caracteres, mayúscula, minúscula y número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              AuthTextField(
                label: 'Teléfono (opcional)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  // 📱 MODIFICADO: 9 dígitos exactos (celular Perú)
                  final phoneRegex = RegExp(r'^\d{9}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Ingresa 9 dígitos numéricos';
                  }
                  return null;
                },
              ),
                        const SizedBox(height: 12),
                        
                        // Botón con gradiente
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            //CA3
                            child: ElevatedButton(
                              onPressed: authService.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authService.isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                      ),
                                    )
                                  : Text(
                                      'Crear Cuenta',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
} 