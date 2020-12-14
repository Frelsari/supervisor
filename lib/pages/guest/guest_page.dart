import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:firevisor/custom_widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Guest extends StatefulWidget {
  @override
  _GuestState createState() => _GuestState();

  final Map data;

  Guest(Map<String, String> machineData) : data = machineData;
}

class _GuestState extends State<Guest> {
  FirebaseFirestore _firestore;
  Map _data;
  Stream dataStream;

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
  void initState() {
    super.initState();
    _data = widget.data;
    _firestore = FirebaseFirestore.instance;
    dataStream =
        _firestore.collection('NTUTLab321').doc(_data['machine']).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('點滴尿袋智慧監控系統'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(
                '@guest_page.dart -> snapshot.error -> ${snapshot.error.toString()}');
            return MessageScreen(
              message: '資料載入出現問題，請稍後再試',
              child: Icon(
                Icons.error_outline,
                color: Colors.lightBlue,
                size: 48.0,
              ),
            );
          } else {
            if (snapshot.hasData) {
              print('@guest_page.dart -> snapshot.data = ${snapshot.data}');
              _data['judge'] = snapshot.data['judge'];
              _data['alarm'] = snapshot.data['alarm'];
              _data['change'] = snapshot.data['change'];
              _data['modedescription'] = snapshot.data['modedescription'];
              _data['power'] = snapshot.data['power'];
              _data['time'] = snapshot.data['time'];
              print('@guest_page.dart -> _data = $_data');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                          builder: (context) {
                            if (_data['judge'] == 'unused') {
                              return StatusCard(
                                statusText: '裝置未使用',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.yellow[700],
                                iconData: Icons.app_blocking,
                              );
                            }
                            if (_data['change'] == '0') {
                              return StatusCard(
                                statusText: '裝置正常',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.green[400],
                                iconData: Icons.check_circle_outline,
                              );
                            }
                            if (_data['change'] == '1') {
                              return StatusCard(
                                statusText: '裝置待更換',
                                infoColor: Colors.grey[800],
                                backgroundColor: Colors.red[400],
                                iconData: Icons.error_outline,
                              );
                            }
                            return StatusCard(
                              statusText: '資料錯誤',
                              infoColor: Colors.white,
                              backgroundColor: Colors.deepPurple,
                              iconData: Icons.clear,
                            );
                          },
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
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Text(
                            _data['expire'] == -1 ? '尚未開始使用' : _data['judge'],
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
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
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
                            '工作紀錄',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 20.0),
                          Flexible(
                            child: Text(
                              _data['time'],
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Divider(color: Colors.black),
                      ),
                    ],
                  ),
                );
              case ConnectionState.waiting:
                return MessageScreen(
                  message: '載入資料中...',
                  child: SpinKitRing(color: Colors.lightBlue),
                );
              case ConnectionState.none:
                return MessageScreen(
                  message: '請檢查手機連線',
                  child: Icon(
                    Icons.perm_scan_wifi_rounded,
                    color: Colors.lightBlue,
                    size: 48.0,
                  ),
                );
              default:
                return MessageScreen(
                  message: 'Unexpected error',
                  child: Icon(
                    Icons.warning_outlined,
                    color: Colors.lightBlue,
                    size: 48.0,
                  ),
                );
            }
          }
        },
      ),
    );
  }
}
