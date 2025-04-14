import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static String tokenKey = 'mytoken';

  static Future<bool> saveToken(value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(tokenKey, value);
  }

// Read Data
  static Future getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(tokenKey);
  }

  static deleteToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(tokenKey);
  }
}
