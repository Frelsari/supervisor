import 'package:flutter/material.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';
import 'package:firevisor/pages/user_lists/guest_list_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:connectivity/connectivity.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:wakelock/wakelock.dart';

// 機器排序方法：編號、狀態、電量
enum ListOrder { title, change, power }

class Supervisor extends StatefulWidget {
  static const sName = "/supervisor";

  @override
  _SupervisorState createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  final firestore = FirebaseFirestore.instance;
  var subscription;
  ListOrder orderOption;
  bool ring = true;

  @override
  void initState() {
    super.initState();
    // 檢查網路是否連接
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((result) => _showCheckInternetDialog());
    // 保持螢幕一直開啟
    Wakelock.enable();
    orderOption = ListOrder.title;
  }

  Stream<QuerySnapshot> _stream(ListOrder order) {
    print('current order = ${order.toString()}');
    var collection = firestore.collection('NTUTLab321');
    switch (order) {
      case ListOrder.change:
        return collection
            .orderBy('change', descending: true)
            .snapshots();
      case ListOrder.power:
        return collection
            .orderBy('power', descending: false)
            .snapshots();
      default:
        return collection
            .orderBy('title', descending: false)
            .snapshots();
    }
  }

  Color getChangeColor(String change) {
    switch (change) {
      case '0':
        return Colors.greenAccent;
      case '1':
        triggerAlarm(ring);
        return Colors.redAccent;
      default:
        return Colors.black12;
    }
  }

  Color getPowerColor(String power) {
    int value = int.parse(power);
    if (value > 50 && value < 101) {
      return Colors.green;
    } else if (value > 25 && value < 51) {
      return Colors.yellow;
    } else if (value > 0 && value < 26) {
      return Colors.red;
    } else {
      return Colors.black12;
    }
  }

  // 狀態 DataColumn 為紅色時，會有一個 check (目前已移除)
  // String remind(String txt) {
  //   if (txt == '1') {
  //     return 'check';
  //   } else {
  //     return '';
  //   }
  // }

  void triggerAlarm(bool ring) {
    if (ring) {
      FlutterRingtonePlayer.playAlarm();
    } else {
      FlutterRingtonePlayer.stop();
    }
  }

  Future<void> _showTimeCurveDialog() async {
    return showDialog<void>(
        context: context,
        builder: (context) {
          // for timecurve testing
          List fakeData = [
            '07:24 已更換',
            '10:47 已更換',
            '12:13 已更換',
            '16:21 已更換',
            '17:33 已更換'
          ];
          var now = DateTime.now();

          return AlertDialog(
              title: Text('歷史紀錄 ${now.month}/${now.day}'),
              content: Container(
                height: 300.0,
                width: 300.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListView.builder(
                  itemCount: fakeData.length,
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.2,
                      indicatorStyle: IndicatorStyle(
                        color: Colors.indigo,
                        width: 40.0,
                        height: 40.0,
                        indicator: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          radius: 100.0,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      ),
                      afterLineStyle: LineStyle(color: Colors.indigo),
                      beforeLineStyle: LineStyle(color: Colors.indigo),
                      endChild: Container(
                        margin: EdgeInsets.all(12.0),
                        child: Text(
                          fakeData[index],
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                FlatButton(
                  child: Text('確定'),
                  onPressed: () => Navigator.pop(context),
                ),
              ]);
        });
  }

  Future<void> _showCheckInternetDialog() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('網路狀態警告'),
          content: Text('請確認網路是否連接。'),
          actions: <Widget>[
            FlatButton(
              child: Text('確認'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // waiting for refactor
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('退出提醒'),
        content: Text('確定退出此應用程式?'),
        actions: <Widget>[
          FlatButton(
            child: Text('否'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text('是'),
            onPressed: () {
              Wakelock.disable();
              FlutterRingtonePlayer.stop();
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }

  // waiting for refactor
  Future<bool> _delete() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('格式化警告'),
        content: Text('確定刪除全部資料?'),
        actions: <Widget>[
          FlatButton(
            child: Text('否'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('是'),
            onPressed: () {
              firestore.collection('NTUTLab321').get().then(
                (snapshot) {
                  for (DocumentSnapshot documentSnapshot in snapshot.docs) {
                    documentSnapshot.reference.delete();
                  }
                },
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 顯示雲端資料
  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> dataRows = snapshot.docs.map(
      (documentSnapshot) {
        if (documentSnapshot['alarm'] == '1') triggerAlarm(ring);
        return DataRow(
          onSelectChanged: (context) => _showTimeCurveDialog(),
          cells: [
            DataCell(
              Text(documentSnapshot['title']),
            ),
            DataCell(
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(documentSnapshot['modedescription']),
              ),
            ),
            DataCell(
              Padding(
                padding: EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundColor: getChangeColor(documentSnapshot['change']),
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: EdgeInsets.all(4.0),
                child: CircleAvatar(
                  child: Text(
                    documentSnapshot['power'],
                    style: TextStyle(color: Colors.blueGrey, fontSize: 20.0),
                  ),
                  backgroundColor: getPowerColor(documentSnapshot['power']),
                ),
              ),
            ),
            DataCell(
              Container(
                width: 100.0,
                child: Text(documentSnapshot['time']),
              ),
            ),
            DataCell(
              GestureDetector(
                child: Icon(Icons.redo),
                onTap: () {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('刪除確認'),
                      content: Text('確定刪除此資料?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('否'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text('是'),
                          onPressed: () {
                            firestore
                                .collection('NTUTLab321')
                                .doc(documentSnapshot.id)
                                .set({
                              'judge': 'unused',
                              'power': '0',
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                onLongPress: () {
                  //長按格式化雲端資料
                  _delete();
                },
              ),
            )
          ],
        );
      },
    ).toList();
    return dataRows;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 退出app提醒
      child: Scaffold(
        appBar: AppBar(
          title: Text('NTUTLab321點滴、尿袋智慧監控系統'),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry>[
                // 功能選單
                PopupMenuItem(
                  child: SwitchListTile(
                    title: Text('鈴聲開關'),
                    value: ring,
                    onChanged: (value) {
                      setState(() => ring = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuDivider(height: 1.0),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('編號排序'),
                    value: ListOrder.title,
                    groupValue: orderOption,
                    onChanged: (value) {
                      setState(() => orderOption = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('狀態排序'),
                    value: ListOrder.change,
                    groupValue: orderOption,
                    onChanged: (value) {
                      setState(() => orderOption = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('電量排序'),
                    value: ListOrder.power,
                    groupValue: orderOption,
                    onChanged: (value) {
                      setState(() => orderOption = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuDivider(height: 1.0),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('帳戶管理'),
                    onTap: () {
                      // 開啟 guest list page
                      BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => GuestListPage(false),
                      ));
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream(orderOption), // 根據所需的項目排序，選擇stream
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    // 如果資料格式不符程式所需，印出錯誤
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: //連接雲端中
                      return Text('連接中...');
                    default: // 顯示雲端內的資料
                      return ListView(
                        children: <Widget>[
                          DataTable(
                            dataRowHeight: 60.0,
                            columnSpacing: 3.0,
                            showCheckboxColumn: false,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text('編號'),
                              ),
                              DataColumn(
                                label: Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text('模式'),
                                ),
                              ),
                              DataColumn(
                                label: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('狀態'),
                                ),
                              ),
                              DataColumn(
                                label: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('電量'),
                                ),
                              ),
                              DataColumn(
                                label: Text('工作紀錄'),
                              ),
                              DataColumn(
                                label: Text('更換病人'),
                              )
                            ],
                            rows: _createRows(snapshot.data),
                          ),
                        ],
                      );
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          //暫時關閉警示鈴
          child: Icon(Icons.alarm_off),
          onPressed: () {
            FlutterRingtonePlayer.stop();
          },
        ),
      ),
    );
  }
}
