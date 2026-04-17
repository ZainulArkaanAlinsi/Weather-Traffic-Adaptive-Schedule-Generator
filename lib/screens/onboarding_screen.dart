import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/gambar 1 on boarding.png',
      'title': 'Jadwal Cerdas via AI',
      'description': 'Aplikasi mengatur ulang jadwal Anda secara otomatis mempertimbangkan cuaca dan jalanan.',
    },
    {
      'image': 'assets/images/gambar 2 on boarding.png',
      'title': 'Dapatkan Insights',
      'description': 'Ketahui kapan waktu terbaik untuk aktivitas luar tanpa kehujanan.',
    },
    {
      'image': 'assets/images/gambar 3 onboarding.png',
      'title': 'Siap Memulai',
      'description': 'Tetapkan API Key Gemini di Pengaturan, dan optimisasi harimu sekarang!',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final box = Hive.box('app_settings');
    await box.put('isOnboardingDone', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1327),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _onboardingData[index]['image']!,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.image_not_supported_rounded, size: 200, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.blueAccent
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Mulai' : 'Lanjut',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
