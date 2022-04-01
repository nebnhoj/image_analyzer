
import 'package:flutter/material.dart';
import 'package:image_analyzer_v2/http_service.dart';
import 'package:image_analyzer_v2/response_body.dart';

import '../request_body.dart';

 HttpService _httpService = new HttpService();

Future<void> analyze(List<Features> features, String fileName) async {
  features.clear();
  features.add(new Features(type: "LABEL_DETECTION"));
  _httpService
      .analyzeImage('gs://image-analyzer-1/${fileName}', features)
      .then((response) {
    print(response.statusCode);
    List<Widget> listIteration = [];

  });
}