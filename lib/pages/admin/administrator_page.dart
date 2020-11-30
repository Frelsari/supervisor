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

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _refreshList() async {
    BlocProvider.of<StaffBloc>(context).add(LoadingStaffEvent());
    BlocProvider.of<GuestBloc>(context).add(LoadingGuestEvent());

    BlocProvider.of<StaffBloc>(context).add(GetStaffEvent());
    BlocProvider.of<GuestBloc>(context).add(GetGuestEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帳戶管理'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _widgetOptions[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Colors.deepPurple,
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
