import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';

class LogoSplash extends StatefulWidget {
  const LogoSplash({super.key});

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

  @override
  void initState() {
    super.initState();

    // Controller for hole to appear (500ms)
    _holeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _holeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _holeController, curve: Curves.easeIn),
    );

    // Controller for logo animation (2000ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoMove = TweenSequence([
      // PHASE 1
      TweenSequenceItem(
        tween: Tween(begin: -20.0, end: 50.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // PHASE 2
      TweenSequenceItem(
        tween: Tween(begin: 50.0, end: 200.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      // PHASE 3
      TweenSequenceItem(
        tween: Tween(begin: 200.0, end: 105.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 30,
      ),
    ]).animate(_logoController);

    // fade out hole as the logo starts to rise high
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

    // logo opacity: starts transparent, only appears when it starts to rise
    _logoOpacity = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 70,
      ),
    ]).animate(_logoController);

    // controller for text (600ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // run animations
    _startAnimations();
  }

  void _startAnimations() async {
    // 1. show the hole animation
    await _holeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. play the bounce-up animation for the logo
    _logoController.forward();

    // 3. wait until the logo reaches center (after 70% of the animation)
    await Future.delayed(const Duration(milliseconds: 1400));

    // 4. start the typing effect for the text
    await _startTypingEffect();

    // 5. navigate to the sign_up screen
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.introApp);
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
                  top: screenHeight / 2 - 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // area for the logo and hole animation
                      SizedBox(
                        width: 70,
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // mouse hole at the bottom
                            Positioned(
                              bottom: 45,
                              child: Opacity(
                                opacity: _holeOpacity.value * _holeFadeOut.value,
                                child: Container(
                                  width: 140,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade400.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // moving logo
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
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: SvgPicture.asset(
                                      'assets/images/Mindly_logo.svg',
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

                      // ✅ "Mindly" text with Google Fonts Poppins
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
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF004455),
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