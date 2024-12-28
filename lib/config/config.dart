import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get testBannerAosId => dotenv.env['TEST_BANNER_AOS_ID'] ?? '';
  static String get bannerAosId => dotenv.env['BANNER_AOS_ID'] ?? '';
  static String get testBannerIosId => dotenv.env['TEST_BANNER_IOS_ID'] ?? '';
  static String get bannerIosId => dotenv.env['BANNER_IOS_ID'] ?? '';
  static String get testRewardAosId => dotenv.env['TEST_REWARD_AOS_ID'] ?? '';
  static String get rewardAosId => dotenv.env['REWARD_AOS_ID'] ?? '';
  static String get testRewardIosId => dotenv.env['TEST_REWARD_IOS_ID'] ?? '';
  static String get rewardIosId => dotenv.env['REWARD_IOS_ID'] ?? '';
}
