import 'package:chatgptclone_curso/services/admob_service.dart';
import 'package:chatgptclone_curso/services/open_ai_service.dart';
import 'package:chatgptclone_curso/widgets/message_bubble.dart';
import 'package:chatgptcurso/services/admob_service.dart';
import 'package:chatgptcurso/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final messages = [];

  TextEditingController _textController = TextEditingController();

  BannerAd? bannerAd;
  RewardedAd? rewardedAd;

  final storage = FlutterSecureStorage();

  int tokens = 5;

  void _writeToStorage() async {
    await storage.write(key: "tokens", value: tokens.toString());
  }

  void _getTokensFromStorage() async {
    String? tokensResponse = await storage.read(key: "tokens");
    tokens = int.parse(tokensResponse!);
    setState(() {});
  }

  void _createBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdmobService.bannerAdId!,
        listener: AdmobService.bannerListener,
        request: const AdRequest())
      ..load();
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdmobService.rewardedAdId!,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => setState(() {
                  rewardedAd = ad;
                }),
            onAdFailedToLoad: (error) => setState(() {
                  rewardedAd = null;
                })));
  }

  void _showRewardedAd() {
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createRewardedAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createRewardedAd();
      });
      rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        setState(() {
          tokens += 1;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getTokensFromStorage();
    _createBannerAd();
    _createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ChatGPT"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("$tokens tokens"),
                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: _showRewardedAd,
                    child: Text("Watch Ad"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  )
                ],
              ),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Column(
            children: [
              bannerAd == null
                  ? Container()
                  : Container(
                      margin: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 52,
                      child: AdWidget(ad: bannerAd!),
                    ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: MessageBubble(
                            message: messages[index]["message"].toString(),
                            isMe: messages[index]["isMe"].toString() == "false"
                                ? false
                                : true),
                      );
                    })),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0))),
                    )),
                    IconButton(
                        onPressed: () async {
                          if (tokens > 0) {
                            tokens -= 1;
                            _writeToStorage();
                            final userMessage = _textController.text;
                            messages.add({
                              "message": _textController.text,
                              "isMe": true
                            });
                            _textController.text = "";

                            setState(() {});
                            final res =
                                await sendTextCompletionRequest(userMessage);
                            messages.add({"message": res, "isMe": false});
                            setState(() {});
                          } else {
                            messages.add({
                              "message": "You don't have tokens",
                              "isMe": false
                            });
                            setState(() {});
                          }
                        },
                        icon: Icon(Icons.send))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
