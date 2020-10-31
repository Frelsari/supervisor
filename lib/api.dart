import 'dart:convert';
import 'package:http/http.dart' as http;

const rootDomain = 'https://us-central1-ntutlab321-23ddb.cloudfunctions.net';
const userPath = rootDomain + '/user';
const staffPath = rootDomain + '/staff';
const guestPath = rootDomain + '/guest';

Future<Map<String, String>> getStaffData(String jwtToken) async {
  final http.Response response =
      await http.get(userPath + '?jwtToken=' + jwtToken);

  if (response.statusCode == 200) {
    final Map data = json.decode(response.body);
    final Map<String, String> userData = {
      'uid': data['uid'],
      'email': data['email'],
      'displayName': data['displayName'],
      'role': data['role'],
    };
    return userData;
  } else {
    print('@api.dart -> getStaffData() -> message = ${response.body}');
    return null;
  }
}

Future<List<Map<String, String>>> getStaffList(String jwtToken) async {
  List<Map<String, String>> staffList;
  String _message = 'Achieved StaffList successfully from firebase.';
  final http.Response response =
      await http.get(staffPath + '?jwtToken=' + jwtToken);
  if (response.statusCode == 200) {
    final List dataList = json.decode(response.body);
    final List<Map<String, String>> _staffList = [];
    for (int i = 0; i < dataList.length; i++) {
      final Map<String, String> staff = {
        'uid': dataList[i]['uid'],
        'email': dataList[i]['email'],
        'displayName': dataList[i]['displayName'],
        'role': dataList[i]['role'],
      };
      _staffList.add(staff);
    }

    if (_staffList != null) {
      staffList = _staffList;
    } else {
      _message = 'StaffList is null.';
    }
  } else {
    _message = response.body;
  }
  print('@api.dart -> getStaffList() -> message = $_message');
  return staffList;
}

Future<List<Map<String, String>>> createStaff(
    Map<String, String> requestData) async {
  String _message = '';
  final String body = json.encode(requestData);
  final http.Response response = await http.post(
    staffPath,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  switch (response.statusCode) {
    case 201:
      // create staff success
      final Map responseData = json.decode(response.body);
      _message = responseData['message'];
      break;
    case 400:
      // password less than 6 chars
      _message = response.body;
      break;
    case 401:
      // jwtToken invalid or expired/permission denied
      _message = response.body;
      break;
    case 500:
      // error occurred when creating account
      final Map responseData = json.decode(response.body);
      _message = responseData['messages']['message'];
      break;
    default:
      _message = 'Unexpected error.';
  }
  print('@api.dart -> createStaff() -> message = $_message');
  final List staffList = await getStaffList(requestData['jwtToken']);
  return staffList;
}

Future<List<Map<String, String>>> deleteStaff(
    {String jwtToken, String uid}) async {
  String _message = '';
  final http.Response response = await http.delete(
    staffPath + '?jwtToken=' + jwtToken + '&uid=' + uid,
    headers: {'Content-Type': 'application/json'},
  );

  switch (response.statusCode) {
    case 200:
      final Map responseData = json.decode(response.body);
      _message = responseData['message'];
      break;
    case 401:
      final Map responseData = json.decode(response.body);
      print(responseData['result']);
      _message = responseData['messages']['message'];
      break;
    case 500:
      _message = response.body;
      break;
    default:
      _message = 'Unexpected error';
  }
  print('@api.dart -> deleteStaff() -> message = $_message');
  final List staffList = await getStaffList(jwtToken);
  return staffList;
}

Future<Map<String, String>> getGuestData(String serialNumber) async {
  final http.Response response =
  await http.get(userPath + '?serialNumber=' + serialNumber);

  switch (response.statusCode) {
    case 200:
      final Map data = json.decode(response.body);
      final Map<String, String> userData = {
        'statusCode': '200',
        'machine': data['machine'],
        'serialNumber': data['serialNumber'].toString(),
        'expire': data['expire'].toString(),
        'position': data['position'],
        'role': data['role'],
        'reGenerateSerialNumberTime': data['reGenerateSerialNumberTime'].toString(),
      };
      return userData;
    case 404:
      final Map<String, String> loginResult = {
        'statusCode': '404',
        'message': '流水號不存在，請使用其他流水號登入',
      };
      return loginResult;
    case 410:
      final Map<String, String> loginResult = {
        'statusCode': '410',
        'message': '流水號已過期，請重新產生流水號或使用其他流水號登入',
      };
      return loginResult;
    default:
      final Map<String, String> loginResult = {
        'statusCode': null,
        'message': 'Unexpected error.',
      };
      return loginResult;
  }
}

Future<List<Map>> getGuestList(String jwtToken) async {
  List<Map> guestList;
  String _message = 'Achieved GuestList successfully from firebase.';
  final http.Response response =
      await http.get(guestPath + '?jwtToken=' + jwtToken);
  if (response.statusCode == 200) {
    final List dataList = json.decode(response.body);
    final List<Map> _guestList = [];
    for (int i = 0; i < dataList.length; i++) {
      final Map guest = {
        'machine': dataList[i]['machine'],
        'position': dataList[i]['position'],
        'reGenerateSerialNumberTime': dataList[i]['reGenerateSerialNumberTime'],
        'serialNumber': dataList[i]['serialNumber'],
        'expire': dataList[i]['expire'],
        'role': dataList[i]['role'],
      };
      _guestList.add(guest);
    }
    if (_guestList != null) {
      guestList = _guestList;
    } else {
      _message = 'GuestList is null.';
    }
  } else {
    _message = response.body;
  }
  print('@api.dart -> getGuestList() -> message = $_message');
  return guestList;
}

Future<List<Map>> regenerateGuestSerialNumber(Map requestData) async {
  String _message = '';
  final String body = json.encode(requestData);
  final http.Response response = await http.post(
    guestPath,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  switch (response.statusCode) {
    case 201:
      // create a guest
      final Map responseData = json.decode(response.body);
      _message = responseData['message'];
      print('expireTimeFromEpoch = ${responseData['guestData']['expire']}');
      break;
    case 202:
      // regenerate guest serial number
      final Map responseData = json.decode(response.body);
      _message = responseData['message'];
      break;
    case 401:
      // jwtToken invalid or expired/permission denied
      _message = response.body;
      break;
    case 500:
      // error occurred when creating a user
      _message = response.body;
      break;
    default:
      _message = 'Unexpected error.';
  }
  print('@api.dart -> regenerateGuestSerialNumber() -> message = $_message');
  final List guestList = await getGuestList(requestData['jwtToken']);
  return guestList;
}

Future<List<Map>> deleteGuest({String jwtToken, String machine}) async {
  String _message = '';
  final http.Response response = await http.delete(
    guestPath + '?jwtToken=' + jwtToken + '&machine=' + machine,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final Map responseData = json.decode(response.body);
    _message = '${responseData['message']}, removed machine: ${responseData['machine']}';
  } else {
    final Map responseData = json.decode(response.body);
    _message = responseData['result'];
  }
  print('@api.dart -> deleteGuest() -> message = $_message');
  final List guestList = await getGuestList(jwtToken);
  return guestList;
}
