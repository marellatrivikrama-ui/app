import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const AayurvaniApp());
}
/// Core application configuration.
class AayurvaniApp extends StatelessWidget {
  const AayurvaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aayurvani',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F0D),
        primaryColor: const Color(0xFF164A32),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF164A32),
          secondary: Color(0xFF2A8B5C),
          surface: Color(0xFF121915),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0F1612).withValues(alpha: 0.6),
          labelStyle: const TextStyle(color: Color(0xFF90A49A)),
          hintStyle: const TextStyle(color: Color(0xFF5A7568)),
          errorStyle: const TextStyle(color: Colors.redAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF24352D)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF24352D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A8B5C), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2A8B5C),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF164A32),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      home: const AuthGatekeeperView(),
    );
  }
}

/// Custom slide and fade route transition builder for premium navigation feel.
Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

// ==========================================
// Reusable Parchment Background Wrapper
// ==========================================
class ParchmentBackgroundWrapper extends StatelessWidget {
  final Widget child;
  const ParchmentBackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/parchment_bg.jpg',
            fit: BoxFit.cover,
            color: const Color(0xFF0A0F0D).withValues(alpha: 0.85),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Color(0xFF121915),
                    Color(0xFF0A0F0D),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

// ==========================================
// 1. AuthGatekeeperView
// ==========================================
class AuthGatekeeperView extends StatefulWidget {
  const AuthGatekeeperView({super.key});

  @override
  State<AuthGatekeeperView> createState() => _AuthGatekeeperViewState();
}

class _AuthGatekeeperViewState extends State<AuthGatekeeperView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGender;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        _createRoute(const AppNavigationShellFrame()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParchmentBackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121915).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF24352D), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A8B5C).withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: Color(0xFF2A8B5C),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "AAYURVANI",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "VEDIC COGNITIVE SYNTHESIS ENGINE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF90A49A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 0.8,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF2A8B5C), size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Age",
                                      prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFF2A8B5C), size: 18),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Enter age";
                                      }
                                      final age = int.tryParse(value);
                                      if (age == null || age <= 0 || age > 120) {
                                        return "Invalid age";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 6,
                                  child: DropdownButtonFormField<String>(
                                    dropdownColor: const Color(0xFF121915),
                                    initialValue: _selectedGender,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Gender",
                                      prefixIcon: Icon(Icons.wc_outlined, color: Color(0xFF2A8B5C), size: 20),
                                    ),
                                    items: ['Male', 'Female', 'Other']
                                        .map((gender) => DropdownMenuItem(
                                              value: gender,
                                              child: Text(gender),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return "Select gender";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Mobile Number",
                                prefixIcon: Icon(Icons.phone_android_outlined, color: Color(0xFF2A8B5C), size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your mobile number";
                                }
                                if (value.trim().length < 8) {
                                  return "Invalid mobile number length";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2A8B5C), size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF90A49A),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter a password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed: _submitForm,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Enter App"),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. AppNavigationShellFrame (Floating Capsule Tab Controller)
// ==========================================
class AppNavigationShellFrame extends StatefulWidget {
  const AppNavigationShellFrame({super.key});

  @override
  State<AppNavigationShellFrame> createState() => _AppNavigationShellFrameState();
}

class _AppNavigationShellFrameState extends State<AppNavigationShellFrame> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    IntroVideoModuleDashboard(),
    DocumentArchivePanelVault(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParchmentBackgroundWrapper(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: _views[_currentIndex],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      width: 320,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF121915).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutBack,
                            alignment: _currentIndex == 0
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF164A32).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: const Color(0xFF2A8B5C).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2A8B5C).withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex = 0;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.analytics_outlined,
                                          color: _currentIndex == 0
                                              ? Colors.white
                                              : const Color(0xFF90A49A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Analysis",
                                          style: TextStyle(
                                            color: _currentIndex == 0
                                                ? Colors.white
                                                : const Color(0xFF90A49A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex = 1;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.folder_open_outlined,
                                          color: _currentIndex == 1
                                              ? Colors.white
                                              : const Color(0xFF90A49A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Your Files",
                                          style: TextStyle(
                                            color: _currentIndex == 1
                                                ? Colors.white
                                                : const Color(0xFF90A49A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }
}

// ==========================================
// 3. IntroVideoModuleDashboard
// ==========================================
class IntroVideoModuleDashboard extends StatefulWidget {
  const IntroVideoModuleDashboard({super.key});

  @override
  State<IntroVideoModuleDashboard> createState() => _IntroVideoModuleDashboardState();
}

class _IntroVideoModuleDashboardState extends State<IntroVideoModuleDashboard> {
  final List<Map<String, String>> _modules = const [
    {
      "title": "Prakruthi Analysis",
      "tagline": "Baseline cellular constitution (Vata-Pitta-Kapha) diagnostics.",
      "videoDuration": "2:15 Min Orientation Video",
    },
    {
      "title": "Vikruthi Deviances",
      "tagline": "Realtime toxic load, biological anomalies & active deviance monitoring.",
      "videoDuration": "3:04 Min Orientation Video",
    },
    {
      "title": "Koshta Profile",
      "tagline": "Digestive tract motility, metabolic absorption index, and waste extraction dynamic.",
      "videoDuration": "1:50 Min Orientation Video",
    },
    {
      "title": "Agni Parikshna",
      "tagline": "Jatharagni strength profiling, metabolic conversions, and enzyme velocity.",
      "videoDuration": "2:45 Min Orientation Video",
    },
    {
      "title": "Satva Bale Track",
      "tagline": "Neurological endurance, sensory stress margins, and mental resilience quotient.",
      "videoDuration": "3:10 Min Orientation Video",
    },
    {
      "title": "Ritu Satmya",
      "tagline": "Circadian rhythm alignment, seasonal adaptive boundaries, and climate response.",
      "videoDuration": "2:20 Min Orientation Video",
    },
    {
      "title": "Datu Sara",
      "tagline": "Structural assessment of 7 primary tissue networks (Rasa to Shukra).",
      "videoDuration": "3:30 Min Orientation Video",
    },
  ];

  void _showOrientationVideo(String moduleTitle, String duration) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (BuildContext context) {
        return _OrientationVideoDialog(moduleTitle: moduleTitle, duration: duration);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("AAYURVANI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF90A49A)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Workspace settings are initialized automatically."),
                  backgroundColor: Color(0xFF164A32),
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF164A32),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF2A8B5C).withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          "SYSTEM STABLE",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "v2.8.5-Cognitive",
                        style: TextStyle(
                          color: Color(0xFF90A49A),
                          fontSize: 10,
                          fontFamily: "Courier",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Analysis Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Select a core medical module to run diagnostic vectors. Preview briefings by tapping video headers.",
                    style: TextStyle(
                      color: Color(0xFF90A49A),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = _modules[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121915).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF24352D), width: 1.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                            color: const Color(0xFF070B09).withValues(alpha: 0.9),
                            child: InkWell(
                              onTap: () => _showOrientationVideo(module["title"]!, module["videoDuration"]!),
                              child: Container(
                                height: 110,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF24352D), width: 1),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.05,
                                        child: GridView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 6,
                                          ),
                                          itemBuilder: (context, idx) => Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white, width: 0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.play_circle_fill,
                                            color: Color(0xFF2A8B5C),
                                            size: 46,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            module["videoDuration"]!.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF90A49A),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.video_library_outlined, size: 10, color: Color(0xFF2A8B5C)),
                                            SizedBox(width: 4),
                                            Text(
                                              "BRIEFING",
                                              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module["title"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  module["tagline"]!,
                                  style: const TextStyle(
                                    color: Color(0xFF90A49A),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.dns_outlined, size: 14, color: Color(0xFF2A8B5C)),
                                        SizedBox(width: 6),
                                        Text(
                                          "VECTORS: 3/3",
                                          style: TextStyle(
                                            color: Color(0xFF5A7568),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          _createRoute(ActiveAssessmentRunnerEngine(title: module["title"]!)),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF164A32),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text("Launch"),
                                          SizedBox(width: 6),
                                          Icon(Icons.bolt, size: 14),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _modules.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _OrientationVideoDialog extends StatefulWidget {
  final String moduleTitle;
  final String duration;

  const _OrientationVideoDialog({
    required this.moduleTitle,
    required this.duration,
  });

  @override
  State<_OrientationVideoDialog> createState() => _OrientationVideoDialogState();
}

class _OrientationVideoDialogState extends State<_OrientationVideoDialog> {
  bool _isPlaying = false;
  bool _isLoading = true;
  double _playbackProgress = 0.0;
  Timer? _playbackTimer;
  String _streamStatus = "Buffering secure synthesis node...";

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
          _streamStatus = "Playing orientation feed (audio-spatial)";
        });
        _startPlaybackTimer();
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      if (_isPlaying) {
        setState(() {
          _playbackProgress += 0.005;
          if (_playbackProgress >= 1.0) {
            _playbackProgress = 0.0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121915),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF24352D), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MODULE BRIEFING VIDEO",
                          style: TextStyle(color: Color(0xFF2A8B5C), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.moduleTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF90A49A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF070B09),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF24352D)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A8B5C)),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Connecting clinical telemetry...",
                          style: TextStyle(color: Color(0xFF90A49A), fontSize: 12, fontFamily: "Courier"),
                        ),
                      ],
                    )
                  else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(12, (index) {
                            return _WaveformBar(
                              isPlaying: _isPlaying,
                              index: index,
                            );
                          }),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _isPlaying ? Colors.red : Colors.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isPlaying ? "LIVE FEED" : "PAUSED",
                            style: const TextStyle(color: Color(0xFF90A49A), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _streamStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF90A49A), fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF2A8B5C),
                      inactiveTrackColor: const Color(0xFF24352D),
                      thumbColor: Colors.white,
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    ),
                    child: Slider(
                      value: _playbackProgress,
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              setState(() {
                                _playbackProgress = val;
                              });
                            },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_playbackProgress, widget.duration),
                        style: const TextStyle(color: Color(0xFF5A7568), fontSize: 11, fontFamily: "Courier"),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isPlaying = !_isPlaying;
                                  _streamStatus = _isPlaying
                                      ? "Playing orientation feed (audio-spatial)"
                                      : "Stream paused";
                                });
                              },
                      ),
                      Text(
                        widget.duration.split(" ")[0],
                        style: const TextStyle(color: Color(0xFF5A7568), fontSize: 11, fontFamily: "Courier"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double progress, String totalStr) {
    try {
      final parts = totalStr.split(" ")[0].split(":");
      final totalMin = int.parse(parts[0]);
      final totalSec = int.parse(parts[1]);
      final totalInSec = (totalMin * 60) + totalSec;
      final currentInSec = (totalInSec * progress).round();
      final min = currentInSec ~/ 60;
      final sec = currentInSec % 60;
      return "${min.toString().padLeft(1, '0')}:${sec.toString().padLeft(2, '0')}";
    } catch (_) {
      return "0:00";
    }
  }
}

class _WaveformBar extends StatelessWidget {
  final bool isPlaying;
  final int index;

  const _WaveformBar({
    required this.isPlaying,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.1, end: isPlaying ? 1.0 : 0.1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      builder: (context, value, child) {
        double heightMultiplier = isPlaying ? (0.3 + 0.7 * sin(value * pi * 2 + index)) : 0.1;
        return Container(
          width: 5,
          height: 15 + (heightMultiplier.abs() * 65),
          decoration: BoxDecoration(
            color: const Color(0xFF2A8B5C).withValues(alpha: isPlaying ? 0.8 : 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. ActiveAssessmentRunnerEngine (Deterministic Rule Engine Driven)
// ==========================================
class AssessmentQuestion {
  final String text;
  final List<String> options;
  const AssessmentQuestion({required this.text, required this.options});
}

class ActiveAssessmentRunnerEngine extends StatefulWidget {
  final String title;

  const ActiveAssessmentRunnerEngine({
    super.key,
    required this.title,
  });

  @override
  State<ActiveAssessmentRunnerEngine> createState() => _ActiveAssessmentRunnerEngineState();
}

class _ActiveAssessmentRunnerEngineState extends State<ActiveAssessmentRunnerEngine> {
  int _currentQuestionIndex = 0;
  final List<int> _selectedOptionIndices = [];

  final Map<String, List<AssessmentQuestion>> _assessmentManifest = const {
    "Prakruthi Analysis": [
      AssessmentQuestion(
        text: "Select the option that best describes your baseline structural physiology and frame:",
        options: [
          "Slender, lighter bone structure, fast active movements",
          "Medium physical stature, well-proportioned musculature",
          "Broad, sturdy skeletal structure, slower deliberate gait",
        ],
      ),
      AssessmentQuestion(
        text: "Choose the statement matching your metabolic reaction to dry, colder drafts:",
        options: [
          "Hypersensitive. Stiffening joints, drying skin, rapid chill",
          "Indifferent to cool air, strongly repelled by severe heat",
          "Comfortable, joint resilience remains high, skin soft",
        ],
      ),
      AssessmentQuestion(
        text: "Select your primary cognitive pattern and natural sleep duration:",
        options: [
          "Fast conceptual assimilation, light or interrupted sleep",
          "Analytical, structured logic, deep moderate sleep duration",
          "Steady systematic memory retention, heavy prolonged sleep",
        ],
      ),
    ],
    "Vikruthi Deviances": [
      AssessmentQuestion(
        text: "Identify any acute gastrointestinal irregularities experienced recently:",
        options: [
          "Recurrent gas, sudden abdominal bloating or dry evacuation",
          "Localized gastric acidity, heartburn, skin irritation post-spiced meal",
          "Heavy sensation in the lower abdomen, slow lethargic digestion",
        ],
      ),
      AssessmentQuestion(
        text: "Have you noticed any changes in skin inflammation or perspiration rates?",
        options: [
          "Dry flaky patches, cold extremities with negligible sweat",
          "Excessive heat, redness, active micro-breakouts or rashes",
          "Moist, clammy skin feeling, congested sweat pores",
        ],
      ),
      AssessmentQuestion(
        text: "Assess your psychological response profile when subjected to stress:",
        options: [
          "Vulnerability to anxiety, pacing thoughts, sleep disruptions",
          "Sudden irritability, critical mindset, mental exhaustion",
          "Withdrawal, extreme complacency, extended fatigue cycles",
        ],
      ),
    ],
    "Koshta Profile": [
      AssessmentQuestion(
        text: "Identify your bowel movement regularity and stool characteristic:",
        options: [
          "Irregular, dry, prone to persistent sluggish evacuation",
          "Extremely regular, soft, responsive to mild spices",
          "Highly stable, solid, completely unaffected by dietary changes",
        ],
      ),
      AssessmentQuestion(
        text: "What is your typical intestinal response to drinking warm cow's milk?",
        options: [
          "Neutralizes bloating, assists in smooth evacuation",
          "Initiates prompt digestion or occasional loose bowels",
          "Minimal noticeable difference, requires high quantities",
        ],
      ),
      AssessmentQuestion(
        text: "Determine your typical system transit times after consuming a heavy meal:",
        options: [
          "Slow transit, discomfort, flatulence and dry signs",
          "Rapid transit, bowel evacuation required within short window",
          "Balanced, steady progress without cellular discomfort",
        ],
      ),
    ],
    "Agni Parikshna": [
      AssessmentQuestion(
        text: "Describe your general daily hunger patterns (Appetite Velocity):",
        options: [
          "Highly erratic; strong hunger one day, absent the next",
          "Sharp, urgent, demanding timely meals with no delay",
          "Slow, moderate, easily skipped without loss of energy",
        ],
      ),
      AssessmentQuestion(
        text: "How does your systemic vitality respond immediately after standard meals?",
        options: [
          "Bloated, dry throat, occasionally accompanied by light headache",
          "Feverish warmth, sweating, or mild localized acidity",
          "Lethargic, extreme sleepiness, feeling physically loaded",
        ],
      ),
      AssessmentQuestion(
        text: "Observe the physiological coating on your tongue upon waking up:",
        options: [
          "Thin greyish coating, primarily situated near the back",
          "Yellowish or reddish tint, situated in the middle zone",
          "Thick, slimy white coating, spanning the entire tongue",
        ],
      ),
    ],
    "Satva Bale Track": [
      AssessmentQuestion(
        text: "Select your predominant cognitive coping posture during sudden crises:",
        options: [
          "Apprehension, rapid focus switching, looking for help",
          "Intense problem-solving, immediate action, quick irritation",
          "Calm withdrawal, buffering thoughts, steady pacing",
        ],
      ),
      AssessmentQuestion(
        text: "Rate your mental endurance boundaries when executing complex tasks:",
        options: [
          "Fatigues quickly, requires frequent environment changes",
          "High threshold but accompanied by progressive internal stress",
          "Excellent long-term focus, highly resilient to disruption",
        ],
      ),
      AssessmentQuestion(
        text: "How is your sensory recovery after a day of intense screens/audio:",
        options: [
          "Sensory overload, difficulty falling asleep, nerve buzzing",
          "Eyes hot/tired, slightly agitated but can shut down",
          "Virtually unaffected, system transitions smoothly to rest",
        ],
      ),
    ],
    "Ritu Satmya": [
      AssessmentQuestion(
        text: "Select the season that produces the highest systemic comfort:",
        options: [
          "Mid-spring; prefers warm, mildly humid climates",
          "Winter; prefers cold, crisp air and warming fires",
          "Summer; comfortable in direct heat and dry sun",
        ],
      ),
      AssessmentQuestion(
        text: "How does your body typically react to seasonal transitions (e.g. monsoon):",
        options: [
          "Joint cracking, skin dryness, dry cough irritations",
          "Allergen sensitivity, heat flushes, metabolic spike",
          "Mucosal accumulation, heavy breathing, weight retention",
        ],
      ),
      AssessmentQuestion(
        text: "What is your natural dietary instinct during sudden cold weather?",
        options: [
          "Craving rich oils, nuts, hot soups, and spices",
          "Craving sweet, cooling, or light grain dishes",
          "Natural desire for fasting, astringents, and hot black teas",
        ],
      ),
    ],
    "Datu Sara": [
      AssessmentQuestion(
        text: "Assess the structural health of your nails, hair, and skeletal joints:",
        options: [
          "Brittle nails, thin split hair, joints snap frequently",
          "Pink flexible nails, fine hair, average joint mobility",
          "Thick, strong nail plates, dense hair, robust silent joints",
        ],
      ),
      AssessmentQuestion(
        text: "Rate your core muscular tone and physical recovery times:",
        options: [
          "Low muscular mass density, slow physical muscle recovery",
          "Aesthetic muscle development, rapid heat recovery",
          "High structural density, excellent physical stamina",
        ],
      ),
      AssessmentQuestion(
        text: "Select the statement describing your skin elasticity and tone:",
        options: [
          "Thin, cold, dry texture, fast to show dehydration fine lines",
          "Warm, highly vascularized complex, sensitive to friction",
          "Thick, oil-balanced texture, smooth surface, resilient to aging",
        ],
      ),
    ],
  };

  void _onOptionSelected(int index) {
    _selectedOptionIndices.add(index);
    if (_currentQuestionIndex < 2) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Navigator.push(
        context,
        _createRoute(ClinicalSynthesisOutputPanel(
          moduleTitle: widget.title,
          selectedIndices: List.from(_selectedOptionIndices),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _assessmentManifest[widget.title] ?? _assessmentManifest["Prakruthi Analysis"]!;
    final currentQuestion = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ParchmentBackgroundWrapper(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "INQUIRY VECTOR ${_currentQuestionIndex + 1} OF 3",
                      style: const TextStyle(
                        color: Color(0xFF2A8B5C),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "${(progress * 100).round()}% SECURE",
                      style: const TextStyle(
                        color: Color(0xFF5A7568),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF121915).withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A8B5C)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 48),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.2, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      key: ValueKey<int>(_currentQuestionIndex),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 36),

                          ...List.generate(currentQuestion.options.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Material(
                                color: const Color(0xFF121915).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _onOptionSelected(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF24352D),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF070B09),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFF2A8B5C), width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: const TextStyle(
                                                color: Color(0xFF2A8B5C),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            currentQuestion.options[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF2A8B5C),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. ClinicalSynthesisOutputPanel (Deterministic Rule Engine Response Mapping)
// ==========================================
class ClinicalSynthesisOutputPanel extends StatelessWidget {
  final String moduleTitle;
  final List<int> selectedIndices;

  const ClinicalSynthesisOutputPanel({
    super.key,
    required this.moduleTitle,
    required this.selectedIndices,
  });

  String _computeDominantBioEnergy() {
    int vata = 0;
    int pitta = 0;
    int kapha = 0;

    for (var idx in selectedIndices) {
      if (idx == 0) vata++;
      if (idx == 1) pitta++;
      if (idx == 2) kapha++;
    }

    if (vata > pitta && vata > kapha) return "VATA DOSHA DOMINANCE (GROUNDING NEEDED)";
    if (pitta > vata && pitta > kapha) return "PITTA DOSHA DOMINANCE (COOLING NEEDED)";
    if (kapha > vata && kapha > pitta) return "KAPHA DOSHA DOMINANCE (STIMULATION NEEDED)";

    if (vata == pitta && vata > 0) return "VATA-PITTA DUAL CONSTITUTION";
    if (pitta == kapha && pitta > 0) return "PITTA-KAPHA DUAL CONSTITUTION";
    if (vata == kapha && vata > 0) return "VATA-KAPHA DUAL CONSTITUTION";

    return "TRIDOSHA BALANCED PROFILE";
  }

  String _getClassicalSpecification() {
    final bio = _computeDominantBioEnergy();
    if (bio.contains("VATA")) {
      return "Ashtanga Hridayam Sutrasthana Chapter 1, Shloka 11: \"Tatra ruksho laghu sheetah kharah sukshmashchalochalah...\" The dry, lightweight, cold, rough, and highly mobile properties of Vata are clinically corrected using grounding, heavy, unctuous (Snigdha), and heat-inducing parameters.";
    } else if (bio.contains("PITTA")) {
      return "Charaka Samhita Sutrasthana Chapter 1, Shloka 60: \"Sasneham ushnam teekshnam cha dravam amlam saram katuh...\" The oily, hot, sharp, liquid, and sour nature of Pitta requires sweet, bitter, and astringent pharmacological correctors combined with systemic cooling regimens.";
    } else {
      return "Sushruta Samhita Sutrasthana Chapter 15, Shloka 3: \"Guru sheetah mriduh snigdhah madhurah sthira pichchhilah...\" The heavy, cold, soft, unctuous, stable, and sticky parameters of Kapha are systematically offset using dry, warm, light, and sharp herbs.";
    }
  }

  String _getEtiologicalMechanics() {
    final bio = _computeDominantBioEnergy();
    if (bio.contains("VATA")) {
      return "Imbalanced Vyana and Samana Vayu velocities have accelerated neural transmission times, causing unstable peristalsis and localized dry colon segments. Telemetry suggests early cell-membrane dehydration and peripheral vascular fluctuations.";
    } else if (bio.contains("PITTA")) {
      return "Accelerated Ranjaka Pitta conversions have generated localized thermal increases in hepatic pathways. The resultant heat accumulation manifests in dermal cell turnover acceleration and hyper-acidic digestive secretions.";
    } else {
      return "Slowing of Kledaka Kapha hydration kinetics has resulted in mucosal stagnation, reduced intracellular transport velocities, and low enzymatic activation. Sub-clinical metrics indicate lymphatic sluggishness and moisture retention.";
    }
  }

  String _getRemediationStrategy() {
    final bio = _computeDominantBioEnergy();
    if (bio.contains("VATA")) {
      return "1. DIET: Favor warm cooked grains, fresh ghee, dates, sesame oils. Eliminate raw leaves and ice-cold water.\n\n"
          "2. THERAPIES: Integrate Abhyanga (warm sesame oil self-massage) and Dashmula herbal decoctions.\n\n"
          "3. LIFESTYLE: Practice slow grounding breathing (Nadi Shodhana) and strict regular sleep times.";
    } else if (bio.contains("PITTA")) {
      return "1. DIET: Favor sweet juicy melons, coconut water, coriander infusions, and cow's milk. Minimize chili, vinegars, and heavy garlic.\n\n"
          "2. THERAPIES: Administer mild cooling oils (Sandalwood, Coconut) and Amalaki extracts.\n\n"
          "3. LIFESTYLE: Avoid direct mid-day sun, integrate calming meditation, and limit excessive heavy lifting.";
    } else {
      return "1. DIET: Favor bitter grains, dry steamed lentils, ginger teas, and black pepper spices. Strictly avoid dairy creams and refined sugar.\n\n"
          "2. THERAPIES: Engage in dry powder massage (Udvartana) and consume Triphala hot infusions before rest.\n\n"
          "3. LIFESTYLE: Maintain high-intensity daily cardio, wake before sunrise, and avoid post-lunch sleep.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dominantEnergy = _computeDominantBioEnergy();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Clinical Synthesis"),
        automaticallyImplyLeading: false,
      ),
      body: ParchmentBackgroundWrapper(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121915).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF24352D), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2A8B5C).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.verified_user_outlined, color: Color(0xFF2A8B5C), size: 22),
                                SizedBox(width: 8),
                                Text(
                                  "INTEGRATED COGNITIVE RUN COMPLETE",
                                  style: TextStyle(
                                    color: Color(0xFF2A8B5C),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              moduleTitle.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Patient Telemetry Reference: AAYU-9844",
                              style: TextStyle(
                                color: Color(0xFF5A7568),
                                fontSize: 10,
                                fontFamily: "Courier",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionHeader("ANALYSIS RESULT PANEL"),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dominantEnergy,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "The cognitive synthesis compiler matched telemetry signals against historical classical profiles with 94.2% diagnostic affinity.",
                              style: TextStyle(color: Color(0xFF90A49A), fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF24352D), thickness: 1, height: 32),

                      _buildSectionHeader("CLASSICAL AYURVEDIC SPECIFICATION"),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _getClassicalSpecification(),
                          style: const TextStyle(
                            color: Color(0xFF90A49A),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFF24352D), thickness: 1, height: 32),

                      _buildSectionHeader("ETIOLOGICAL MECHANICS ANALYSIS"),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _getEtiologicalMechanics(),
                          style: const TextStyle(
                            color: Color(0xFF90A49A),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFF24352D), thickness: 1, height: 32),

                      _buildSectionHeader("GENERAL REMEDIATION STRATEGY"),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _getRemediationStrategy(),
                          style: const TextStyle(
                            color: Color(0xFF90A49A),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1612).withValues(alpha: 0.9),
                  border: const Border(
                    top: BorderSide(color: Color(0xFF24352D), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Telemetry data routed to doctor workstation. Notification successfully queued.",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFF164A32),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text(
                          "Route Core Data to Doctor",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF164A32),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        label: const Text(
                          "Close Workspace",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF24352D), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

// ==========================================
// 6. DocumentArchivePanelVault
// ==========================================
class DocumentArchivePanelVault extends StatefulWidget {
  const DocumentArchivePanelVault({super.key});

  @override
  State<DocumentArchivePanelVault> createState() => _DocumentArchivePanelVaultState();
}

class _DocumentArchivePanelVaultState extends State<DocumentArchivePanelVault> {
  bool _isRefreshing = false;

  void _refreshVault() {
    setState(() {
      _isRefreshing = true;
    });
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Archive synchronization completed. Zero local files detected."),
            backgroundColor: Color(0xFF164A32),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Document Vault"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Health Archives Vault",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Secure storage for your historical diagnostic transcripts and clinical sign-offs.",
                style: TextStyle(
                  color: Color(0xFF90A49A),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121915).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF24352D), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B09),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF24352D), width: 1.2),
                          ),
                          child: _isRefreshing
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A8B5C)),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(
                                  Icons.folder_open,
                                  color: Color(0xFF2A8B5C),
                                  size: 48,
                                ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Vault is Empty",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No historical transcripts have been archived yet.\nComplete diagnostic runs to generate reports.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF90A49A),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        OutlinedButton.icon(
                          onPressed: _isRefreshing ? null : _refreshVault,
                          icon: const Icon(Icons.sync, size: 16, color: Colors.white),
                          label: const Text(
                            "Sync Records",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF24352D), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}