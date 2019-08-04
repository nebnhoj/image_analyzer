import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';


import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async' show Future;
//import 'package:firebase_admob/firebase_admob.dart';

import 'http_service.dart';
import 'list_item.dart';
import 'request_body.dart';
import 'response_body.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image _image;
  bool _isLoading= false;
  HttpService _httpService = new HttpService();
  List<Features> features = new List();
  List<Widget> _listWidget = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  void _showDialog( ) {
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
                        Icons.camera ,
                        color:  Colors.blueGrey,
                        size: 18,
                      ),
                      new Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: new Text(
                            "TAKE PHOTO",
                            style: new TextStyle(
                                fontSize: 14,
                                color:  Colors.blueGrey,
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();

                    takePicture(  ImageSource.camera);


                  },
                ),
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    takePicture( ImageSource.gallery);
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
                                      color:  Colors.blueGrey,
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


  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-2063494299935345/5535111171').then((response){
      myBanner..load()..show();
    });

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
        actions: <Widget>[
         _isLoading ?new CircularProgressIndicator(): IconButton(icon: Icon(Icons.camera_alt,color: Colors.white,),onPressed: _showDialog,)
         ]

      ),
      body: Container(
        padding: EdgeInsets.only(top: 10,left: 10,right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(child: _image!=null?Container(child:_image,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),):new Icon(Icons.image,size: 300,color: Colors.blueGrey,),),
            Container(
              height: 200,
              padding: EdgeInsets.only(top: 20),
              child: new SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:Container(child:  Column(children: _listWidget,),)))
          ],
        ),
      ),
        // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['business', 'photo','analytics','accounting','bitcoin','games','pubg','mobile legends','camera'],
    contentUrl: 'https://flutter.io',
     childDirected: false,
     testDevices: <String>[], // Android emulators are considered test devices
  );

  BannerAd myBanner = BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: 'ca-app-pub-2063494299935345/6820805285',
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
  Future takePicture(  ImageSource imageSource) async {
    var _imageFile = await ImagePicker.pickImage(
        source: imageSource, maxHeight: 1920, maxWidth: 1080);
    File croppedFile = await ImageCropper.cropImage(
       toolbarTitle: "Crop Image",
      toolbarWidgetColor: Colors.blueGrey,
      circleShape: true,
      sourcePath: _imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 768,
      maxHeight: 768,
    ).catchError((error) {
      print(error);
    });
    setState(() {
      _image =Image.file(croppedFile,height: 300,);
      _isLoading = true;
    });

    _httpService.uploadImageUsingDio(croppedFile  ).then((fileName){

      analyze(fileName);
       setState(() {
          _isLoading = false;
       });
     });
  }

  Future<void> analyze(String fileName) async {
    features.clear();
    features.add(new Features(type:"LABEL_DETECTION") );
      _httpService.analyzeImage('gs://image-analyzer-1/${fileName}', features).then((response){
      print(response.statusCode);
      List<Widget> listIteration = List();
       ResponseBody.fromJson(response.data).responses.forEach((data){
         listIteration.addAll(data.labelAnnotations.map((data)=>new Item(labelAnnotations: data)).toList());
      });
       setState(() {
         _listWidget = listIteration;
       });
    });
  }
}
