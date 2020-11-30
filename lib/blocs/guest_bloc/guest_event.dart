part of 'guest_bloc.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();
}

class LoadingGuestEvent extends GuestEvent {
  @override
  List<Object> get props => [];
}

class RegenerateSerialNumberEvent extends GuestEvent {
  final String machine;
  final String expireTime;
  final String position;

  RegenerateSerialNumberEvent({
    this.machine,
    this.expireTime,
    this.position,
  })  : assert(machine != null),
        assert(expireTime != null);

  @override
  List<Object> get props => [
        this.machine,
        this.expireTime,
        this.position,
      ];
}

class GetGuestEvent extends GuestEvent {
  @override
  List<Object> get props => [];
}

class DeleteGuestEvent extends GuestEvent {
  final String machine;

  DeleteGuestEvent({this.machine}) : assert(machine != null);

  @override
  List<Object> get props => [this.machine];
}
