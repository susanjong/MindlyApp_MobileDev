import 'package:flutter/material.dart';

class LogoSplash extends StatefulWidget {
  const LogoSplash({Key? key}) : super(key: key);

  @override
  State<LogoSplash> createState() => _LogoSplashState();
}

class _LogoSplashState extends State<LogoSplash>
    with TickerProviderStateMixin {
  late final AnimationController _holeController;
  late final AnimationController _logoController;
  late final AnimationController _textController;

  late final Animation<double> _holeOpacity;
  late final Animation<double> _logoMove;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _holeFadeOut;
  late final Animation<double> _textOpacity;

  String _displayedText = '';
  final String _fullText = 'Mindly';

      // FASE 1: Logo mulai dari BAWAH lingkaran abu (tidak terlihat)
    // FASE 2: Melesat naik tinggi (40%)
    // FASE 3: Turun ke center dengan bounce (30%)

  @override
  void initState() {
    super.initState();

    // Controller untuk lubang muncul (500ms)
    _holeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _holeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _holeController, curve: Curves.easeIn),
    );

    // Controller untuk animasi logo (2000ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoMove = TweenSequence([
      // FASE 1: Mulai dari bawah lingkaran (posisi -20, di bawah lubang)
      TweenSequenceItem(
        tween: Tween(begin: -20.0, end: 50.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // FASE 2: Melesat naik tinggi
      TweenSequenceItem(
        tween: Tween(begin: 50.0, end: 200.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      // FASE 3: Turun ke center dengan bounce
      TweenSequenceItem(
        tween: Tween(begin: 200.0, end: 105.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30,
      ),
    ]).animate(_logoController);

    // Lubang fade out saat logo mulai naik tinggi
    _holeFadeOut = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 75,
      ),
    ]).animate(_logoController);

    // Logo opacity: mulai transparan, baru muncul saat mulai naik
    _logoOpacity = TweenSequence([
      // Transparan saat di bawah
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 10,
      ),
      // Muncul saat mulai loncat
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      // agar tetap terlihat
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 70,
      ),
    ]).animate(_logoController);

    // Controller untuk text (600ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Jalankan animasi
    _startAnimations();
  }

  void _startAnimations() async {
    // 1. Munculkan lubang
    await _holeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Logo bounce naik
    _logoController.forward();
    
    // 3. Tunggu logo sampai posisi center (setelah 70% animasi logo)
    await Future.delayed(const Duration(milliseconds: 1400));

    // 4. Typing effect untuk text
    await _startTypingEffect();

    // 5. Navigate ke sign_up screen
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/sign_up');
    }
  }

  Future<void> _startTypingEffect() async {
    _textController.forward();
    for (int i = 0; i <= _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          _displayedText = _fullText.substring(0, i);
        });
      }
    }
  }

  @override
  void dispose() {
    _holeController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _holeController,
            _logoController,
            _textController
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: screenHeight / 2 - 80, // Center vertikal
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Area untuk animasi logo dan lubang
                      SizedBox(
                        width: 70, // Dikurangi agar logo tetap center
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center, 
                          clipBehavior: Clip.none,
                          children: [
                            // Lubang tikus di bawah
                            Positioned(
                              bottom: 45,
                              child: Opacity(
                                opacity: _holeOpacity.value * _holeFadeOut.value,
                                child: Container(
                                  width: 140,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade400.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Logo yang bergerak (mulai dari bawah, baru muncul saat naik)
                            Positioned(
                              bottom: 45 + _logoMove.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: Container(
                                  width: 60, 
                                  height: 60, 
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, 
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/images/LogoAplikasi.png', 
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover, 
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Teks "Mindly" DI SAMPING logo - muncul setelah logo selesai transisi
                      AnimatedOpacity(
                        opacity: _textOpacity.value,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Transform.translate(
                          offset: Offset(0, (1 - _textOpacity.value) * 10), 
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15,   
                              bottom: 110,  
                            ),
                            child: Text(
                              _displayedText,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                                letterSpacing: 0.5,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}