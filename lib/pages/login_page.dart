import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:firevisor/pages/user_page.dart';

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final serialNumberController = TextEditingController();

  bool _isStaffLogin = false;
  bool _enabled = true;

  final infoIncompleteSnackBar = SnackBar(
    content: ListTile(
      leading: Icon(Icons.info),
      title: Text('使用者資訊未輸入完整'),
    ),
    backgroundColor: Colors.red[700],
    duration: Duration(seconds: 1, milliseconds: 500),
  );

  void staffLogin() {
    final String _username = usernameController.text.trim();
    final String _password = passwordController.text;
    if (_username.isEmpty || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(infoIncompleteSnackBar);
      return;
    }

    BlocProvider.of<AuthenticateBloc>(context)
        .add(AuthenticateLoggingInEvent());
    BlocProvider.of<AuthenticateBloc>(context).add(AuthenticateLogInEvent(
      username: _username,
      password: _password,
    ));
  }

  void guestLogin() {
    final _serialNumber = serialNumberController.text.trim();
    if (_serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(infoIncompleteSnackBar);
      return;
    }

    BlocProvider.of<AuthenticateBloc>(context)
        .add(AuthenticateLoggingInEvent());
    BlocProvider.of<AuthenticateBloc>(context).add(SerialNumberLogInEvent(
      serialNumber: _serialNumber,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5.0,
      child: BlocConsumer<AuthenticateBloc, AuthenticateState>(
        listener: (context, state) {
          if (state is AuthenticateLoggedInState) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => User(),
            ));
          } else {
            SnackBar snackBar;
            if (state is AuthenticateLoggingInState) {
              snackBar = SnackBar(
                content: ListTile(
                  leading: Icon(Icons.whatshot),
                  title: Text('登入中，請稍候...'),
                ),
                backgroundColor: Colors.teal[700],
                duration: Duration(seconds: 1, milliseconds: 500),
              );
            } else if (state is AuthenticateLogInFailedState) {
              snackBar = SnackBar(
                content: ListTile(
                  leading: Icon(Icons.info),
                  title: Text(state.failureMessage),
                ),
                backgroundColor: Colors.red[700],
                duration: Duration(seconds: 1, milliseconds: 500),
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          _enabled = !(state is AuthenticateLoggingInState ||
              state is AuthenticateLoggedInState);
          return Column(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                leading: (_isStaffLogin
                    ? Icon(Icons.assignment_ind)
                    : Icon(Icons.airline_seat_flat)),
                title: (_isStaffLogin ? Text('醫護人員登入') : Text('家屬登入')),
                trailing: Switch(
                  value: _isStaffLogin,
                  onChanged: (value) {
                    setState(() {
                      _isStaffLogin = value;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _isStaffLogin = !_isStaffLogin;
                  });
                },
              ),
              Builder(
                builder: (context) {
                  if (_isStaffLogin) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _enabled,
                            keyboardType: TextInputType.text,
                            controller: usernameController,
                            obscureText: false,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.account_circle),
                                hintText: '帳號'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _enabled,
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.https), hintText: '密碼'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            child: Text('登入'),
                            onPressed: (_enabled ? staffLogin : null),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _enabled,
                            keyboardType: TextInputType.text,
                            controller: serialNumberController,
                            obscureText: false,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.apps_sharp),
                                hintText: '流水號'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            child: Text('登入'),
                            onPressed: (_enabled ? guestLogin : null),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class Login extends StatelessWidget {
  static const sName = "/login_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        toolbarHeight: 0,
      ),
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 44.0),
              Text(
                'NTUT Lab 321',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '點滴尿袋智慧監控系統',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Image.asset(
                'images/NTUT-logo.png',
                height: 200.0,
                width: 200.0,
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: LoginCard(),
              ),
              SizedBox(height: 20.0),
              Text(
                '特別感謝：台北榮民醫院 - 蘇澳暨圓山分院 協助開發',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
