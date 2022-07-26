import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/roundbutton.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  double controllerint = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      // upperBound: 100,
    );

    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation = ColorTween(
      begin: Colors.blueGrey,
      end: Colors.white,
    ).animate(controller);

    controller.forward();

    controller.addListener(
      () {
        setState(() {});
        // controllerint = animation.value * 100;
        debugPrint(
          animation.value.toString(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var children2 = <Widget>[
      Row(
        children: <Widget>[
          Hero(
            tag: "logo",
            child: SizedBox(
              height: 60,
              child: Image.asset(
                'images/logo.png',
              ),
            ),
          ),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "flash chat",
                textStyle: const TextStyle(
                  fontSize: 45.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(
        height: 48.0,
      ),
      RoundButton(
        color: Colors.lightBlueAccent,
        text: "Log In",
        function: () {
          Navigator.pushNamed(context, "loginPage");
        },
      ),
      RoundButton(
        color: Colors.blueAccent,
        text: "Register",
        function: () {
          Navigator.pushNamed(context, "registerPage");
        },
      ),
    ];
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children2,
        ),
      ),
    );
  }
}
