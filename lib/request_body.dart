class RequestBody {
  List<Requests> requests;

  RequestBody({this.requests});

  RequestBody.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = new List<Requests>();
      json['requests'].forEach((v) {
        requests.add(new Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.requests != null) {
      data['requests'] = this.requests.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  ImageSrc image;
  List<Features> features;

  Requests( {this.image, this.features});

  Requests.fromJson(Map<String, dynamic> json) {
    image = json['image'] != null ? new ImageSrc.fromJson(json['image']) : null;
    if (json['features'] != null) {
      features = new List<Features>();
      json['features'].forEach((v) {
        features.add(new Features.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.image != null) {
      data['image'] = this.image.toJson();
    }
    if (this.features != null) {
      data['features'] = this.features.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageSrc {
  Source source;

  ImageSrc({this.source});

  ImageSrc.fromJson(Map<String, dynamic> json) {
    source =
    json['source'] != null ? new Source.fromJson(json['source']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.source != null) {
      data['source'] = this.source.toJson();
    }
    return data;
  }
}

class Source {
  String gcsImageSrcUri;

  Source({this.gcsImageSrcUri});

  Source.fromJson(Map<String, dynamic> json) {
    gcsImageSrcUri = json['gcsImageUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gcsImageUri'] = this.gcsImageSrcUri;
    return data;
  }
}

class Features {
  String type;
  Features({this.type});

  Features.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    return data;
  }
}
