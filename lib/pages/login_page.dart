import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/authenticate_bloc/authenticate_bloc.dart';
import 'package:firevisor/pages/user_page.dart';

class Login extends StatelessWidget {
  static const sName = "/login_page";

  // 按下登入鈕後留給動畫的時間
  Duration get loginTime => Duration(milliseconds: 500);
  final int numberOfRetry = 20;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<String> _authUser({String username, String password}) async {
      BlocProvider.of<AuthenticateBloc>(context).add(AuthenticateLogInEvent(
        username: username,
        password: password,
      ));

      for (int i = 0; i < numberOfRetry; i++) {
        final state = BlocProvider.of<AuthenticateBloc>(context).state;

        if (!(state is AuthenticateLogInFailedState ||
            state is AuthenticateLoggedInState)) {
          await Future.delayed(loginTime);
        } else if (state is AuthenticateLoggedInState) {
          return null;
        } else if (state is AuthenticateLogInFailedState) {
          return '使用者名稱錯誤或是密碼錯誤，請再試一次';
        }
      }
      return '連線至伺服器時發生錯誤，請再試一次。';
    }

    Widget _loginCard(bool _enabled) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // username
              enabled: _enabled,
              keyboardType: TextInputType.text,
              controller: usernameController,
              obscureText: false,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.account_circle), hintText: '帳號'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              // password
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
            child: Builder(
              builder: (context) {
                if (_enabled) {
                  return RaisedButton(
                    child: Text('登入'),
                    onPressed: () async {
                      context
                          .bloc<AuthenticateBloc>()
                          .add(AuthenticateLoggingInEvent());

                      final String _username = usernameController.text.trim();
                      final String _password = passwordController.text;
                      String _message;

                      if (_username.isEmpty || _password.isEmpty) {
                        _message = '帳號或密碼未輸入完整';
                      } else {
                        // show logging in snackBar
                        final SnackBar loggingSnackBar = SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.whatshot),
                              SizedBox(width: 10.0),
                              Text('正在登入...'),
                            ],
                          ),
                          backgroundColor: Colors.teal[900],
                          duration: Duration(milliseconds: 500),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(loggingSnackBar);

                        // get login result & message
                        _message = await _authUser(
                          username: _username,
                          password: _password,
                        );
                      }

                      if (_message == null) {
                        // login success
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => User(), // 離開登入畫面 (轉移到內部)
                        ));
                      } else {
                        context
                            .bloc<AuthenticateBloc>()
                            .add(AuthenticateLogOutEvent());
                        // login failed
                        final errorSnackBar = SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error),
                              SizedBox(width: 10.0),
                              Text(_message),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(errorSnackBar);
                      }
                    },
                  );
                } else {
                  return RaisedButton(
                    child: Text('登入'),
                    onPressed: null,
                  );
                }
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.0),
              Text(
                '點滴尿袋智慧監控系統',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Image.asset(
                'images/TVGHE-logo.png',
                height: 200.0,
                width: 200.0,
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 5.0,
                  child: BlocBuilder<AuthenticateBloc, AuthenticateState>(
                    builder: (context, state) => _loginCard(
                        !(state is AuthenticateLoggingInState ||
                            state is AuthenticateLoggedInState)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
