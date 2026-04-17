import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNextScreen();
  }

  Future<void> _checkNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final box = Hive.box('app_settings');
    final bool isOnboardingDone = box.get('isOnboardingDone', defaultValue: false);

    if (isOnboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1327),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gambar splash screen.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.calendar_month_rounded, size: 100, color: Colors.blueAccent),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
