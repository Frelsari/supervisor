import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';

class GuestListPage extends StatelessWidget {
  final bool _isAdmin;

  @override
  GuestListPage(bool isAdmin) : _isAdmin = isAdmin;

  Future<void> _refreshList(BuildContext context) async {
    BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帳戶管理'),
        backgroundColor: _isAdmin ? Colors.deepPurple : Colors.indigo,
      ),
      body: GuestList(_isAdmin),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Colors.indigo,
        onPressed: () => _refreshList(context),
      ),
    );
  }
}

class GuestList extends StatelessWidget {
  final bool _isAdmin;
  final Color _themeColor;

  @override
  GuestList(bool isAdmin)
      : _isAdmin = isAdmin,
        _themeColor = isAdmin ? Colors.deepPurple : Colors.indigo;

  Future<void> _showRegenerateSerialNumberDialog(
      BuildContext context, Map guest) async {
    final expireController = TextEditingController();
    final regenerateSerialNumberDialog = AlertDialog(
      title: Text('重新產生流水號'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.datetime,
              controller: expireController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.timer_rounded),
                hintText: '過期時間(天)',
              ),
            ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text(
            '取消',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(
            '確定',
            style: TextStyle(color: _themeColor),
          ),
          onPressed: () {
            final String expireText = expireController.text.trim();
            if (expireText.contains(new RegExp('^[0-9]*\$'))) {
              BlocProvider.of<GuestBloc>(context)
                  .add(RegenerateSerialNumberEvent(
                machine: guest['machine'],
                expireTime: expireText,
                position: guest['position'],
              ));
            } else {
              print('Expire time can only contain numbers');
            }
            Navigator.pop(context);
          },
        )
      ],
    );
    final regenerateBannedDialog = AlertDialog(
      title: Text('重新產生流水號'),
      content: Text('請稍後再產生新的流水號！'),
      actions: [
        FlatButton(
          child: Text(
            '確定',
            style: TextStyle(color: Colors.deepPurple),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    final int milliseconds = guest['reGenerateSerialNumberTime'];
    final DateTime regenerateTime =
        DateTime.fromMillisecondsSinceEpoch(milliseconds);

    return showDialog<void>(
      context: context,
      builder: (context) {
        print('test');
        if ((!_isAdmin) && regenerateTime.compareTo(DateTime.now()) > 0)
          return regenerateBannedDialog;
        else
          return regenerateSerialNumberDialog;
      },
    );
  }

  Future<void> _showGuestInfoDialog(BuildContext context, Map guest) async {
    return showDialog(
      context: context,
      builder: (context) {
        final DateTime expireTime =
            new DateTime.fromMillisecondsSinceEpoch(guest['expire']);
        final Duration timeLeft = expireTime.difference(new DateTime.now());

        return AlertDialog(
          title: Text(guest['serialNumber']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('床室號：${guest['position']}'),
                SizedBox(height: 12.0),
                Text('帳號過期時間：${formatTimeLeftToMessage(timeLeft)}'),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                '確定',
                style: TextStyle(
                  color: _themeColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteGuestDialog(BuildContext context, Map guest) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('永久刪除使用者'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('你確定要刪除 ${guest['serialNumber']} 嗎？'),
                  Text('此動作將無法復原。'),
                ],
              ),
            ),
            actions: [
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text(
                  '確定',
                  style: TextStyle(
                    color: _themeColor,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ]);
      },
    );
  }

  String formatTimeLeftToMessage(Duration _time) {
    if (_time.isNegative) return '已過期';
    if (_time.inMinutes <= 1) return '剩餘 1 分鐘';
    if (_time.inHours < 1) return '剩餘 ${_time.inMinutes} 分鐘';
    if (_time.inDays < 1) return '剩餘 ${_time.inHours} 小時';
    return '剩餘 ${_time.inDays} 天';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<GuestBloc, GuestState>(
        builder: (context, state) {
          if (state is ShowGuestState) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: state.guestList.length,
              itemBuilder: (context, index) {
                final Map guest = state.guestList[index];
                return ListTile(
                  leading: Container(
                    width: 20.0,
                    alignment: Alignment.center,
                    child: Icon(Icons.airline_seat_flat),
                  ),
                  title: Text(guest['serialNumber']),
                  subtitle: Text(guest['position']),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'regenerateSerialNumber',
                        child: Row(
                          children: [
                            Icon(Icons.fiber_new_rounded),
                            SizedBox(width: 8.0),
                            Text('重生流水號'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'deletePermanently',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever),
                            SizedBox(width: 8.0),
                            Text('永久刪除'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (action) {
                      switch (action) {
                        case 'regenerateSerialNumber':
                          _showRegenerateSerialNumberDialog(context, guest);
                          break;
                        case 'deletePermanently':
                          _showDeleteGuestDialog(context, guest);
                          break;
                        default:
                          print('@guest_list_page -> popup menu error');
                      }
                    },
                  ),
                  onTap: () => _showGuestInfoDialog(context, guest),
                );
              },
            );
          } else {
            return Center(
              child: Text('無使用者'),
            );
          }
        },
      ),
    );
  }
}
