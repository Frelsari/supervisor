import 'package:firevisor/pages/user_pages/supervisor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firevisor/blocs/authenticate_bloc/authenticate_bloc.dart';

import 'user_pages/administrator_page.dart';
import 'user_pages/guest_page.dart';

class User extends StatelessWidget {
  static const sName = "/user_page";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticateBloc, AuthenticateState>(
      builder: (context, state) {
        if (state is AuthenticateLoggedInState) {
          final Map userData = state.loginResult;
          switch (userData['role']) {
            case 'administrator':
              return Administrator();
            case 'staff':
              return Supervisor();
            case 'guest':
              return Guest(userData);
            default:
              return Scaffold(
                appBar: null,
                body: Center(
                  child: Text('ROLE ERROR'),
                ),
              );
          }
        } else {
          return Scaffold(
            appBar: null,
            body: Center(
              child: Text('AUTH ERROR'),
            ),
          );
        }
      },
    );
  }
}
