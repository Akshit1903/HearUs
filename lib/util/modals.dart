import '../util/sharedPrefHelper.dart';

class DataFromSharedPref {
  var myName, myUsername, myEmail, myProfilePic, myUserId;
  DataFromSharedPref() {
    getData();
  }

  Future<String> getData() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
    myUserId = await SharedPreferenceHelper().getUserId();
    return myName;
  }

  Future<String> getMyName() {
    return myName;
  }
}
