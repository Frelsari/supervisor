part of 'authenticate_bloc.dart';

abstract class AuthenticateEvent extends Equatable {
  const AuthenticateEvent();
}

class AuthenticateLoggingInEvent extends AuthenticateEvent {
  @override
  List<Object> get props => [];
}

class AuthenticateLogInEvent extends AuthenticateEvent {
  final String username, password;

  const AuthenticateLogInEvent({
    this.username,
    this.password,
  })  : assert(username != null),
        assert(password != null);

  @override
  List<Object> get props => [
        this.username,
        this.password,
      ];
}

class SerialNumberLogInEvent extends AuthenticateEvent {
  final String serialNumber;

  const SerialNumberLogInEvent({this.serialNumber})
      : assert(serialNumber != null);

  @override
  List<Object> get props => [this.serialNumber];
}

class AuthenticateLogOutEvent extends AuthenticateEvent {
  @override
  List<Object> get props => [];
}

class AuthenticateLogInFailedEvent extends AuthenticateEvent {
  final String message;

  const AuthenticateLogInFailedEvent({this.message});

  @override
  List<Object> get props => [this.message];
}
