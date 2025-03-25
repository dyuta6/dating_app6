import 'package:dating_app/ads/strings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds {
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  void loadInterstitialAd({bool showAfterLoad = false}) {
    InterstitialAd.load(
        adUnitId: KAdStrings.interstitalAd1,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
            if (showAfterLoad) showInterstitalAd();
          },
          onAdFailedToLoad: (LoadAdError error) {},
        ));
  }

  void showInterstitalAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: KAdStrings.bannerAd1,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }
}
