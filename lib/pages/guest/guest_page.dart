import 'package:flutter/material.dart';

class Guest extends StatelessWidget {
  static const sName = "/guest_page";

  final Map _data;

  Guest(Map<String, String> machineData) : _data = machineData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('家屬資訊'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12.0),
              Text(
                '機器狀態',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.0),
              ListTile(
                leading: Icon(Icons.airline_seat_flat),
                title: Text('床室號：${_data['judge']}'),
              ),
              ListTile(
                leading: Icon(Icons.build),
                title: Text('模式：${_data['modedescription']}'),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: (_data['change'] == 1 ? Colors.red : Colors.green),
                ),
                title: Text(
                  '狀態：' + (_data['change'] == 1 ? '待更換' : '正常'),
                  style: TextStyle(
                    color:
                    (_data['change'] == 1 ? Colors.red : Colors.green),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.battery_full),
                title: Text('電量：${_data['power']}%'),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('日期：${_data['time']}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
