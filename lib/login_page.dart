import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  final supabase = Supabase.instance.client;

  // Mod değiştirme işlemi
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  // Giriş veya kayıt işlemini gerçekleştirir.
  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLogin) {
      // Giriş işlemi
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Giriş başarılı!")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Giriş başarısız: $e")));
      }
    } else {
      // Kayıt işlemi
      final confirm = _confirmPasswordController.text.trim();
      final username = _usernameController.text.trim();

      if (password != confirm) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Şifreler uyuşmuyor.")));
        return;
      }

      try {
        await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'username': username},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt başarılı! Lütfen e-postanı kontrol et."),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Kayıt başarısız: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'assets/egypttexture.webp',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Form içeren merkez bileşen
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // Giriş veya Kayıt Formu
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin
                              ? "Yeniden hoş geldin!"
                              : "Yolculuğun burada başlıyor\nİlk adımını at",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: "E-mail",
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_isLogin)
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: "Kullanıcı adı",
                              prefixIcon: Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        if (!_isLogin) const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Şifre",
                            prefixIcon: Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_isLogin)
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Şifreyi onayla",
                              prefixIcon: Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 14,
                            ),
                          ),
                          child: Text(_isLogin ? "Giriş yap" : "Kayıt ol"),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            _isLogin
                                ? "Hesabın yok mu? Kayıt ol"
                                : "Hesabın mı var? Giriş yap",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
