import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'home_screen.dart'; // Твой импорт главного экрана

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, // Прибирає червону стрічку DEBUG
    home: EduWay(),
  )); 
}

class EduWay extends StatefulWidget {
  const EduWay({super.key});

  @override
  State<EduWay> createState() => _EduWayState();
}

class _EduWayState extends State<EduWay> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ParticlesFly(
            height: screenHeight,
            width: screenWidth,
            connectDots: true,
            numberOfParticles: 50,
            particleColor: Colors.white, 
            maxParticleSize: 2,
            speedOfParticles: 1.5,
            lineColor: const Color.fromARGB(255, 250, 250, 252),
          ),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to EduWay!',
                    style: GoogleFonts.pixelifySans(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 56, 204).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person, color: Colors.white),
                                    labelText: "Ім'я",
                                    labelStyle: TextStyle(color: Colors.white),
                                    errorStyle: TextStyle(color: Color.fromARGB(255, 250, 0, 0), fontSize: 13),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Введіть ім'я";
                                    }
                                    return null;
                                  },
                                ),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                                    labelText: 'Пароль',
                                    labelStyle: TextStyle(color: Colors.white),
                                    errorStyle: TextStyle(color: Color.fromARGB(255, 255, 0, 0), fontSize: 13),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Введіть пароль';
                                    }
                                    if (value.length < 6) {
                                      return 'Пароль має містити від 6 symbols';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Зареєстровано')),
                            );

                            // Передаємо ім'я користувача у HomeScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                  userName: _usernameController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 30, 56, 204),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Створити акаунт',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      bool success = await AuthService.login(username, password);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Успішний вхід')),
          );

          // Передаємо ім'я користувача у HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: username,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Помилка входу')),
          );
        }
      }
    }
  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 30, 56, 204),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Увійти в наявний',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
