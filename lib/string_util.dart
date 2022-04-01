
import 'package:intl/intl.dart';

class StringUtil{


  static String toPercent(double? num){
    if(num==null){
      return '';
    }
    final formatter = new NumberFormat("#0.00 %" );
    return formatter.format(num );
   }


}
