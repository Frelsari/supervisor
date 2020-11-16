import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/guest_bloc/guest_bloc.dart';
import 'package:firevisor/blocs/staff_bloc/staff_bloc.dart';
import 'package:firevisor/pages/staff/staff_list_page.dart';
import '../guest/guest_list_page.dart';

class Administrator extends StatefulWidget {
  static const sName = "/administrator_page";

  @override
  _AdministratorState createState() => _AdministratorState();
}

class _AdministratorState extends State<Administrator> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [StaffList(), GuestList(true)];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    BlocProvider.of<StaffBloc>(context).add(GetStaffEvent());
    BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    if (_selectedIndex == 0) {
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
    } else {
      final machineController = TextEditingController();
      final expireController = TextEditingController();
      final positionController = TextEditingController();

      final _guestAlertDialog = AlertDialog(
        title: Text('新增家屬'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.0),
              TextField(
                keyboardType: TextInputType.text,
                controller: machineController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.computer),
                  hintText: '機器編號',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                keyboardType: TextInputType.datetime,
                controller: expireController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.timer_rounded),
                  hintText: '過期時間(天)',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                keyboardType: TextInputType.text,
                controller: positionController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  hintText: '機器位置',
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
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(
              '新增用戶',
              style: TextStyle(
                color: Colors.deepPurple,
              ),
            ),
            onPressed: () {
              final String expireText = expireController.text.trim();
              if (expireText.contains(new RegExp('^[0-9]*\$'))) {
                BlocProvider.of<GuestBloc>(context).add(RegenerateSerialNumberEvent(
                  machine: machineController.text.trim(),
                  expireTime: expireText,
                  position: positionController.text.trim(),
                ));
              } else {
                print('Expire time can only contain numbers');
              }
              Navigator.pop(context);
            },
          ),
        ],
      );

      return showDialog(
        context: context,
        builder: (context) => _guestAlertDialog,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帳戶管理'),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton(
            onSelected: (action) {
              print('@administrator_page.dart -> action = $action');
              switch (action) {
                case 'refresh':
                  BlocProvider.of<StaffBloc>(context).add(GetStaffEvent());
                  BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('登出'),
              ),
            ],
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Colors.indigo,
        onPressed: _refreshList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind),
            label: '醫護人員',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airline_seat_flat),
            label: '家屬床位',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
