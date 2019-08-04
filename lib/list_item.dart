import 'package:flutter/material.dart';
import 'package:image_analyzer_v2/response_body.dart';
import 'package:image_analyzer_v2/string_util.dart';

class Item extends StatelessWidget {
  final LabelAnnotations labelAnnotations;
  const Item({Key key, this.labelAnnotations}) : super(key: key);

  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: 5,left: 20),
      child: Row(
        children: <Widget>[
          Text(
            '${StringUtil.toPercent(labelAnnotations.score)}',
            style: TextStyle(
                color: (labelAnnotations.score * 100) > 80
                    ? Colors.green
                    : (labelAnnotations.score * 100) > 60 ? Colors.orangeAccent
                    :   Colors.redAccent ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('${labelAnnotations.description}'),
          )
        ],
      ),
    );
  }
}
