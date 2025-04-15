import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/egypttexture.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isLogin)
                          TextField(
                            controller: usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: inputDecoration('Kullanıcı Adı'),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration('E-posta'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration('Şifre'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: handleAuth,
                          child: Text(
                            isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              isLogin
                                  ? 'Hesabın yok mu? '
                                  : 'Zaten hesabın var mı? ',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin ? 'Kayıt ol' : 'Giriş yap',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
    );
  }
}
