import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:async' show Future;
//import 'package:firebase_admob/firebase_admob.dart';

import 'http_service.dart';
import 'list_item.dart';
import 'request_body.dart';
import 'response_body.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image? _image;
  bool _isLoading = false;
  HttpService _httpService = new HttpService();
  List<Features> features = [];
  List<Widget> _listWidget = [];
  final ImagePicker _picker = ImagePicker();
  static final AdRequest request = AdRequest(
    keywords: <String>[
      'business',
      'photo',
      'analytics',
      'accounting',
      'bitcoin',
      'games',
      'pubg',
      'camera'
    ],
    contentUrl: 'https://flutter.io',
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedAd();
    _createInterstitialAd();

  }


  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Image Analyzer'), actions: <Widget>[
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInterstitialAd2();

        },
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt_outlined, color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(child: Container(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Watch Ads to use the service'),
            Center(
              child: _image != null
                  ? Container(
                child: _image,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)),
              )
                  : new Icon(
                Icons.image,
                size: 300,
                color: Colors.blueGrey,
              ),
            ),
            if (_anchoredBanner != null)
              Container(
                color: Colors.green,
                width: _anchoredBanner!.size.width.toDouble(),
                height: _anchoredBanner!.size.height.toDouble(),
                child: AdWidget(ad: _anchoredBanner!),
              ),
            Container(
              child: Column(
                children: _listWidget,
              ),
            ),

          ],
        ),
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final BannerAd banner = BannerAd(
      size: AdSize.fullBanner,
      request: request,
      adUnitId: 'ca-app-pub-2063494299935345/7110667280',
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }


  Future takePicture(ImageSource imageSource) async {
    final _imageFile = await _picker.pickImage(
        source: imageSource, maxHeight: 1920, maxWidth: 1080);
    File? croppedFile = await ImageCropper().cropImage(
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: "Crop Image",
        toolbarWidgetColor: Colors.blueGrey,
      ),
      cropStyle: CropStyle.circle,
      sourcePath: _imageFile!.path,
      maxWidth: 768,
      maxHeight: 768,
    ).catchError((error) {
      print(error);
    });
    setState(() {
      _image = Image.file(
        croppedFile!,
        height: 300,
      );
      _isLoading = true;
    });

    _httpService.uploadImageUsingDio(croppedFile!).then((fileName) {
      analyze(fileName);
      setState(() {
        _isLoading = false;
      });
      _showInterstitialAd2();
    });
  }

  Future<void> analyze(String fileName) async {
    features.clear();
    features.add(new Features(type: "LABEL_DETECTION"));
    _httpService
        .analyzeImage('gs://image-analyzer-1/${fileName}', features)
        .then((response) {
      print(response.statusCode);
      List<Widget> listIteration = [];
      ResponseBody
          .fromJson(response.data)
          .responses!
          .forEach((data) {
        listIteration.addAll(data.labelAnnotations!
            .map((data) => new Item(labelAnnotations: data))
            .toList());
      });
      setState(() {
        _listWidget = listIteration;
      });
    });
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-2063494299935345/4491208968',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }
  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        _showDialog();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }  void _showInterstitialAd2() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
        _showDialog();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Container(
            width: double.maxFinite,
            height: 60,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new GestureDetector(
                  child: new Row(
                    children: <Widget>[
                      new Icon(
                        Icons.camera,
                        color: Colors.blueGrey,
                        size: 18,
                      ),
                      new Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: new Text(
                            "TAKE PHOTO",
                            style: new TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();

                    takePicture(ImageSource.camera);
                  },
                ),
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    takePicture(ImageSource.gallery);
                  },
                  child: new Container(
                      margin: EdgeInsets.only(top: 10),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Icon(
                              Icons.image,
                              color: Colors.blueGrey,
                              size: 18,
                            ),
                            new Container(
                              height: 18,
                              margin: EdgeInsets.only(left: 10),
                              child: Text(""),
                            ),
                            new Expanded(
                                child: Text(
                                  "CHOOSE PHOTO FROM GALLERY",
                                  maxLines: 1,
                                  style: new TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500),
                                ))
                          ])),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-2063494299935345/1782022472',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        _showDialog();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward:(AdWithoutView ad, RewardItem rewardItem) {
      print('${rewardItem.type} - ${rewardItem.amount}');
     });
    _rewardedAd = null;
  }
}