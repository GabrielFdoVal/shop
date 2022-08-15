import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/excepitons/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { SignUp, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

AuthMode _authMode = AuthMode.Login;

class _AuthFormState extends State<AuthForm> {
  final _passwordControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSignUp() => _authMode == AuthMode.SignUp;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.SignUp;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Ocorreu um erro"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Fechar"),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }
    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    Auth auth = Provider.of(
      context,
      listen: false,
    );

    try {
      if (_isLogin()) {
        await auth.signin(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        //Registrar
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: _isLogin() ? 310 : 400,
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return "Informe um e-mail válido";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                controller: _passwordControler,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return "Informe uma senha válida";
                  }
                  return null;
                },
              ),
              if (_isSignUp())
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Confirmar senha'),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  validator: _isLogin()
                      ? null
                      : (_password) {
                          final password = _password ?? '';
                          if (password != _passwordControler.text) {
                            return "Senhas informadas não conferem";
                          }
                          return null;
                        },
                ),
              const SizedBox(
                height: 20,
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    _isLogin() ? 'Entrar' : 'Registrar',
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _isLogin() ? "Dejesa Registrar" : "Já possuí conta?",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
