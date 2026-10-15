import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MaterialApp(
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

  // controllers to read values from the fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // called by the "create account" button
  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final code = await AuthService.register(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (code == 201) {
      _showMessage('Акаунт створено');
    } else if (code == 409) {
      _showMessage("Таке ім'я вже зайняте");
    } else if (code == -1) {
      _showMessage("Немає з'єднання з сервером");
    } else {
      _showMessage('Помилка сервера');
    }
  }

  // called by the "log in" button
  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await AuthService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      _showMessage('Вхід виконано');
      // TODO: navigate to the main screen here
    } else {
      _showMessage("Невірне ім'я або пароль");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // animated background
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

          // main widgets
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
                              color: const Color.fromARGB(255, 30, 56, 204)
                                  .withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              children: [
                                // username field
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.white),
                                    labelText: "Ім'я",
                                    labelStyle: TextStyle(color: Colors.white),
                                    errorStyle: TextStyle(
                                      color: Color.fromARGB(255, 250, 0, 0),
                                      fontSize: 13,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Введіть ім'я";
                                    }
                                    return null;
                                  },
                                ),

                                // password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.lock, color: Colors.white),
                                    labelText: 'Пароль',
                                    labelStyle: TextStyle(color: Colors.white),
                                    errorStyle: TextStyle(
                                      color: Color.fromARGB(255, 255, 0, 0),
                                      fontSize: 13,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Введіть пароль';
                                    }
                                    if (value.length < 6) {
                                      return 'Пароль має містити від 6 символів';
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
                          onPressed: _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 30, 56, 204),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
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
                          onPressed: _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 30, 56, 204),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
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