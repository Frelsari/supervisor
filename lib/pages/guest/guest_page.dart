import 'package:flutter/material.dart';

class Guest extends StatelessWidget {
  static const sName = "/guest_page";

  final Map _data;

  Guest(Map<String, String> machineData) : _data = machineData;

  Color getPowerColor(String s) {
    int power = int.parse(s);
    if (power > 50 && power < 101) {
      return Colors.green;
    } else if (power > 25 && power < 51) {
      return Colors.yellow;
    } else if (power > 0 && power < 26) {
      return Colors.red;
    } else {
      return Colors.black12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('點滴尿袋智慧監控系統'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: _data['change'] == '0'
                    ? Colors.green
                    : Colors.red,
                elevation: 5.0,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  leading: Icon(
                    _data['change'] == '0'
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: Colors.white,
                    size: 44.0,
                  ),
                  title: Text(
                    _data['change'] == '0' ? '正常' : '待更換',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 40.0),
                Text(
                  '床室號',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20.0),
                Text(
                  _data['judge'],
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 40.0),
                Text(
                  '模    式',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20.0),
                Text(
                  _data['modedescription'],
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 40.0),
                Text(
                  '電    量',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20.0),
                CircleAvatar(
                  backgroundColor: getPowerColor(_data['power']),
                  child: Text(_data['power']),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(color: Colors.black),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 40.0),
                Text(
                  '工作記錄',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20.0),
                Text(
                  _data['time'],
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
