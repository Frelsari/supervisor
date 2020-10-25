import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';

class StaffList extends StatelessWidget {
  Future<void> _showDeleteStaffDialog(BuildContext context, Map staff) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('刪除醫護人員'),
          content: SingleChildScrollView(
            child: Text('你確定要刪除 ${staff['displayName']} 嗎？'),
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
                '刪除',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                BlocProvider.of<StaffBloc>(context)
                    .add(DeleteStaffEvent(deleteUid: staff['uid']));
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _showStaffInfoDialog(BuildContext context, Map staff) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('用戶資料'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('用戶名稱：${staff['displayName']}'),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text(
                '確認',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is ShowStaffState) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              itemCount: state.staffList.length,
              itemBuilder: (context, index) {
                final Map staff = state.staffList[index];
                return ListTile(
                  leading: Container(
                    width: 20.0,
                    alignment: Alignment.center,
                    child: Icon(Icons.assignment_ind),
                  ),
                  title: Text(staff['displayName']),
                  subtitle: Text('醫護人員'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteStaffDialog(context, staff),
                  ),
                  onTap: () => null,
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
