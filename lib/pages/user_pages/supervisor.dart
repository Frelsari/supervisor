import 'package:firevisor/custom_widgets/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';
import 'package:firevisor/pages/user_lists/guest_list_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  static const themeColor = Colors.indigo;
  FirebaseFirestore _firestore;
  Stream _dataStream;
  List<Map<String, String>> machineList = [];
  ListOrder order;
  bool ring = true;
  var subscription;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // 保持螢幕一直開啟
    Wakelock.enable();

    // 檢查網路是否連接
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((result) => _showCheckInternetDialog());

    // 初始化 firebase 集合
    _firestore = FirebaseFirestore.instance;
    _dataStream = _firestore.collection('NTUTLab321').snapshots();

    // 預設排列方式
    order = ListOrder.title;
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
          List<String> fakeData = <String>[
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
                  child: Text('確定', style: TextStyle(color: themeColor)),
                  onPressed: () => Navigator.pop(context),
                ),
              ]);
        });
  }

  Future<void> _showCheckInternetDialog() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('網路狀態警告'),
          content: Text('請確認網路是否連接。'),
          actions: <Widget>[
            FlatButton(
              child: Text('確認'),
              color: themeColor,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showDeleteMachineDataDialog(String machineId) async {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('刪除確認'),
            content: Text('確定刪除此資料？'),
            actions: <Widget>[
              FlatButton(
                child: Text('取消', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('刪除', style: TextStyle(color: themeColor)),
                onPressed: () {
                  _firestore.collection('NTUTLab321').doc(machineId).set({
                    'judge': 'unused',
                    'power': '0',
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<bool> _showDeleteAllDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('格式化警告'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('確定刪除全部資料？'),
              Text('所有資料將無法復原。'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('取消', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('確定', style: TextStyle(color: themeColor)),
            onPressed: () {
              _firestore.collection('NTUTLab321').get().then(
                (snapshot) {
                  for (var snapshot in snapshot.docs) {
                    snapshot.reference.delete();
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

  // 退出 App 提醒
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('即將退出程式'),
        content: Text('確定退出此應用程式？'),
        actions: <Widget>[
          FlatButton(
            child: Text('取消', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text('退出', style: TextStyle(color: themeColor)),
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

  List<DataRow> getMachineRows() {
    List<DataRow> rows = [];
    switch (order) {
      case ListOrder.title:
        machineList.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case ListOrder.change:
        machineList.sort((a, b) => a['change'].compareTo(b['change']));
        break;
      case ListOrder.power:
        machineList.sort((a, b) {
          int ap = int.parse(a['power']);
          int bp = int.parse(b['power']);
          return bp.compareTo(ap);
        });
        break;
    }

    for (var machine in machineList) {
      if (machine['alarm'] == '1') triggerAlarm(ring);
      DataRow row = DataRow(
        onSelectChanged: (context) => _showTimeCurveDialog(),
        cells: [
          DataCell(
            Text(machine['title']),
          ),
          DataCell(
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(machine['modedescription']),
            ),
          ),
          DataCell(
            Padding(
              padding: EdgeInsets.all(4.0),
              child: CircleAvatar(
                backgroundColor: getChangeColor(machine['change']),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: EdgeInsets.all(4.0),
              child: CircleAvatar(
                child: Text(
                  machine['power'],
                  style: TextStyle(color: Colors.blueGrey, fontSize: 20.0),
                ),
                backgroundColor: getPowerColor(machine['power']),
              ),
            ),
          ),
          DataCell(
            Container(
              width: 100.0,
              child: Text(machine['time']),
            ),
          ),
          DataCell(
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.redo),
              ),
              onTap: () => _showDeleteMachineDataDialog(machine['id']),
              onLongPress: () => _showDeleteAllDialog(),
            ),
          )
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 退出app提醒
      child: Scaffold(
        appBar: AppBar(
          title: Text('NTUTLab321 點滴尿袋智慧監控系統'),
          backgroundColor: themeColor,
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
                    groupValue: order,
                    onChanged: (value) {
                      setState(() => order = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('狀態排序'),
                    value: ListOrder.change,
                    groupValue: order,
                    onChanged: (value) {
                      setState(() => order = value);
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('電量排序'),
                    value: ListOrder.power,
                    groupValue: order,
                    onChanged: (value) {
                      setState(() => order = value);
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
                stream: _dataStream, // 根據所需的項目排序，選擇stream
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  // 如果資料格式不符程式所需，印出錯誤
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return MessageScreen(
                      message: '資料載入出現問題，請稍後再試',
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.lightBlue,
                        size: 48.0,
                      ),
                    );
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        // 讀取當前機器狀態
                        List<Map<String, String>> _machines = [];
                        snapshot.data.docs.forEach((doc) {
                          Map<String, String> machine = {
                            'id': doc.id,
                            'change': doc['change'],
                            'modedescription': doc['modedescription'],
                            'power': doc['power'],
                            'time': doc['time'].toString(),
                            'title': doc['title'],
                          };
                          _machines.add(machine);
                          // print(machine);
                        });
                        // 覆寫機器列表
                        machineList = _machines;
                      }
                      // 顯示雲端內的資料
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
                            rows: getMachineRows(),
                          ),
                        ],
                      );
                    case ConnectionState.waiting: // 連接雲端中
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
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          // 暫時關閉警示鈴
          child: Icon(Icons.alarm_off),
          backgroundColor: themeColor,
          onPressed: () => FlutterRingtonePlayer.stop(),
        ),
      ),
    );
  }
}
