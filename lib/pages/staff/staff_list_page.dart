import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';

class StaffList extends StatelessWidget {
  Future<void> _showAddStaffDialog(BuildContext context,) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final displayNameController = TextEditingController();

    final _staffAlertDialog = AlertDialog(
      title: Text('新增醫護人員'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: usernameController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle),
                hintText: '帳號',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.https),
                hintText: '密碼',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              keyboardType: TextInputType.text,
              controller: displayNameController,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: '用戶名稱',
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
            '新增用戶',
            style: TextStyle(color: Colors.deepPurple),
          ),
          onPressed: () {
            // should check if args are valid
            BlocProvider.of<StaffBloc>(context).add(AddStaffEvent(
              email: usernameController.text,
              password: passwordController.text,
              displayName: displayNameController.text,
            ));
            Navigator.pop(context);
          },
        ),
      ],
    );

    return showDialog(
      context: context,
      builder: (context) => _staffAlertDialog,
    );
  }

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
              itemCount: state.staffList.length + 1,
              itemBuilder: (context, index) {
                if (index == state.staffList.length) {
                  return ListTile(
                    leading: Icon(Icons.add, color: Colors.deepPurple),
                    title: Text(
                      '新增醫護人員',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showAddStaffDialog(context),
                  );
                } else {
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
                  );
                }
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
