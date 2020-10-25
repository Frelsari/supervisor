part of 'guest_bloc.dart';

abstract class GuestState extends Equatable {
  const GuestState();
}

class ShowGuestState extends GuestState {
  final List<Map> guestList;

  ShowGuestState({this.guestList}): assert(guestList != null);

  @override
  List<Object> get props => [this.guestList];
}

class NoGuestState extends GuestState {
  @override
  List<Object> get props => [];
}
