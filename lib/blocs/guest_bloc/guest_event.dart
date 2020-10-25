part of 'guest_bloc.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();
}

class AddGuestEvent extends GuestEvent {
  final String machine;
  final String expireTime;
  final String position;

  AddGuestEvent({
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
