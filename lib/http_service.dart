import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_analyzer_v2/request_body.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'dart:convert';

class HttpService {
  Future<String> uploadImageUsingDio(File _image ) async {
    Dio dio = Dio();
    String fileName = basename(_image.path);
    Options options = Options(
      headers: {
        "Content-Type": "multipart/form-data", // set content-length
      },
    );


    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(_image.path, filename: fileName),

    });
    String name = '${DateTime.now().millisecondsSinceEpoch}.${basename(_image.path).split('.').last}';

    String url = 'https://www.googleapis.com/upload/storage/v1/b/image-analyzer-1/o?name=${name}';


     await dio.post(url, data: formData, options: options).then((response){
      print(response);
    }).catchError((error){
      print(error);
     });
    return name;
  }

  Future<Response> analyzeImage(String uri,List<Features> features) async{
    Dio dio = Dio();
    List<Requests> requests = [];
    requests.add(new Requests(image: ImageSrc(source: new Source(gcsImageSrcUri: uri)),features: features));

    String url = 'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDE1SphLw569Pd2ZQLziBbvBSFGSV3KZH0';
    var requestBody = RequestBody(requests: requests);
    print(json.encode(requestBody.toJson()).toString());
    return await dio.post(url, data: json.encode(requestBody.toJson()) );

  }
}
