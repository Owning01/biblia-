import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_providers.dart';
import '../../../data/services/auth_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              hintText: 'Correo electrónico',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(
              hintText: 'Contraseña',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _submit(auth),
            child: Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() {
              _isLogin = !_isLogin;
              _error = null;
            }),
            child: Text(
              _isLogin
                  ? '¿No tienes cuenta? Crear una'
                  : '¿Ya tienes cuenta? Iniciar sesión',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AuthService auth) async {
    setState(() => _error = null);
    try {
      if (_isLogin) {
        await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Error de autenticación');
    }
  }
}
