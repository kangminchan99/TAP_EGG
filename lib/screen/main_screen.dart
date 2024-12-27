import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tap_aggs/controller/egg_controller.dart';
import 'package:tap_aggs/screen/last_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  final EggController eggController = Get.put(EggController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _shakeEgg() {
    _animationController.reset();
    _animationController.forward().then((_) {
      _animationController.reverse(); // 애니메이션 복귀
    });

    eggController.touchEgg();
  }

  String getImageAsset() {
    if (eggController.tapCount.value > 20) {
      return 'assets/images/last_egg.png';
    } else if (eggController.tapCount.value > 10) {
      return 'assets/images/first_broken_egg.png';
    } else {
      return 'assets/images/clean_egg.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              eggController.reset();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => GestureDetector(
                onTap: () {
                  if (eggController.tapCount >= 21) {
                    Get.to(() => LastScreen());
                  }
                },
                child: Text(
                  eggController.tapCount < 21
                      ? '${eggController.tapCount}'
                      : 'GO',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _shakeEgg,
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Obx(
                    () => SizedBox(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.width / 1.2,
                      child: Image.asset(getImageAsset()),
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
