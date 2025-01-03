import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tap_egg/controller/egg_controller.dart';
import 'package:tap_egg/screen/last_screen.dart';
import 'package:tap_egg/service/admob_service.dart';

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

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;

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

    _createBannerAd();
    _loadRewardedAd();
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

  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdmobService.bannerAdUnitId!,
        listener: AdmobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdmobService.rewardAdUnitId!, // 테스트 광고 ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        try {
          eggController.rewardedGet();
        } catch (e) {
          Fluttertoast.showToast(msg: "오류가 발생했습니다. 나중에 다시 시도해주세요!");
        }
      });

      _rewardedAd = null;
    }
  }

  String getImageAsset() {
    if (eggController.tapCount.value > 100000000) {
      return 'assets/images/last_egg.png';
    } else if (eggController.tapCount.value > 50000000) {
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
        leading: IconButton(
          onPressed: () {
            if (_rewardedAd != null) {
              _showRewardedAd();
            } else {
              Fluttertoast.showToast(msg: '아직 광고를 볼 수 없어요');
            }
          },
          icon: const Icon(
            Icons.card_giftcard_sharp,
            color: Colors.red,
          ),
        ),
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
                  if (eggController.tapCount >= 100000000) {
                    Get.to(() => const LastScreen());
                  }
                },
                child: Text(
                  eggController.tapCount < 100000000
                      ? '${eggController.tapCount}'
                      : 'Watch the video?',
                  style: TextStyle(
                    color: eggController.tapCount < 100000000
                        ? Colors.black
                        : Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
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
      bottomNavigationBar: _bannerAd == null
          ? Container(
              height: 75,
            )
          : SizedBox(
              height: 75,
              child: AdWidget(
                ad: _bannerAd!,
              ),
            ),
    );
  }
}
