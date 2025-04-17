import 'package:connectivity_plus/connectivity_plus.dart';

class CheckInternet {
  static Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }
}
