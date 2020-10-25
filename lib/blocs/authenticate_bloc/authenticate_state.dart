part of 'authenticate_bloc.dart';

abstract class AuthenticateState extends Equatable {
  const AuthenticateState();

  @override
  List<Object> get props => [];
}

class AuthenticateLogInFailedState extends AuthenticateState {
  final String failureMessage;
  AuthenticateLogInFailedState({this.failureMessage});
}

class AuthenticateLoggedInState extends AuthenticateState {
  final Map<String, String> loginResult;
  AuthenticateLoggedInState({this.loginResult});

  @override
  List<Object> get props => [this.loginResult];
}

class AuthenticateLoggingInState extends AuthenticateState {}

class AuthenticateLoggedOutState extends AuthenticateState {}
