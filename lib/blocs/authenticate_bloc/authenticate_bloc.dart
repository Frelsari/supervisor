import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:firevisor/user_repository.dart';

part 'authenticate_event.dart';

part 'authenticate_state.dart';

class AuthenticateBloc extends Bloc<AuthenticateEvent, AuthenticateState> {
  final UserRepository _userRepository;

  AuthenticateBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(AuthenticateLoggedOutState());

  @override
  Stream<AuthenticateState> mapEventToState(
    AuthenticateEvent event,
  ) async* {
    if (event is AuthenticateLogInEvent) {
      yield* _mapAuthenticateLogInEventToState(
        event.username,
        event.password,
      );
    } else if (event is AuthenticateLogOutEvent) {
      yield* _mapAuthenticateLogOutToState();
    } else if (event is AuthenticateLogInFailedEvent) {
      yield* _mapAuthenticateLogInFailedEventToState();
    } else if (event is AuthenticateLoggingInEvent) {
      yield* _mapAuthenticateLoggingInEventToState();
    }
  }

  // 使用者登入時觸發
  Stream<AuthenticateState> _mapAuthenticateLogInEventToState(
    String username,
    String password,
  ) async* {
    final bool isLoggedIn = _userRepository.isLoggedIn();
    Map loginResult;

    if (isLoggedIn) {
      print(
          '@authenticate_bloc.dart -> _mapAuthenticateLogInEventToState -> user already logged in');
    } else {
      try {
        loginResult = await _userRepository.logInWithUsernameAndPassword(
          username: username,
          password: password,
        );

        print(
            '@authenticate_bloc.dart -> _mapAuthenticateLogInEventToState -> loginResult = ${loginResult.toString()}');

        if (loginResult == null) {
          yield AuthenticateLogInFailedState();
          throw Exception;
        }
      } on Exception catch (e) {
        print(e);
        yield AuthenticateLogInFailedState();
      }
    }
    yield AuthenticateLoggedInState(loginResult: loginResult);
  }

  // 使用者登出時觸發
  Stream<AuthenticateState> _mapAuthenticateLogOutToState() async* {
    final bool isLoggedIn = _userRepository.isLoggedIn();
    if (isLoggedIn) {
      _userRepository.logOut();
    } else {
      print(
          '@authenticate_bloc -> _mapAuthenticateLogOutToState -> user is already null');
    }
    yield AuthenticateLoggedOutState();
  }

  Stream<AuthenticateState> _mapAuthenticateLogInFailedEventToState() async* {
    yield AuthenticateLogInFailedState();
  }

  Stream<AuthenticateState> _mapAuthenticateLoggingInEventToState() async* {
    yield AuthenticateLoggingInState();
  }
}
