class ResponseBody {
  List<Responses>? responses;

  ResponseBody({this.responses});

  ResponseBody.fromJson(Map<String, dynamic> json) {
    if (json['responses'] != null) {
      responses =[];
      json['responses'].forEach((v) {
        responses!.add(new Responses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.responses != null) {
      data['responses'] = this.responses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Responses {
  List<LabelAnnotations>? labelAnnotations;

  Responses({this.labelAnnotations});

  Responses.fromJson(Map<String, dynamic> json) {
    if (json['labelAnnotations'] != null) {
      labelAnnotations = [];
      json['labelAnnotations'].forEach((v) {
        labelAnnotations!.add(new LabelAnnotations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.labelAnnotations != null) {
      data['labelAnnotations'] =
          this.labelAnnotations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LabelAnnotations {
  String? mid;
  String? description;
  double? score;
  double? topicality;

  LabelAnnotations({this.mid, this.description, this.score, this.topicality});

  LabelAnnotations.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    description = json['description'];
    score = json['score'];
    topicality = json['topicality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mid'] = this.mid;
    data['description'] = this.description;
    data['score'] = this.score;
    data['topicality'] = this.topicality;
    return data;
  }
}
