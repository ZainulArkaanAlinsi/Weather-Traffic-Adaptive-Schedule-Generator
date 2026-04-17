import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
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
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 800),
                              child: Container(
                                height: 320,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.1),
                                      blurRadius: 40,
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  _onboardingData[index]['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.rocket_launch_rounded, size: 200, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            FadeInUp(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                _onboardingData[index]['title']!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInUp(
                              delay: const Duration(milliseconds: 400),
                              child: Text(
                                _onboardingData[index]['description']!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.6,
                                ),
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 10),
                            height: 6,
                            width: _currentPage == index ? 32 : 12,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.textMuted.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Row(
                          children: [
                            if (_currentPage < _onboardingData.length - 1)
                              Expanded(
                                child: TextButton(
                                  onPressed: _finishOnboarding,
                                  child: Text(
                                    'Skip',
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            if (_currentPage < _onboardingData.length - 1)
                              const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  if (_currentPage == _onboardingData.length - 1) {
                                    _finishOnboarding();
                                  } else {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.easeInOutQuart,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.accent],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next Step',
                                      style: AppTextStyles.button,
                                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
