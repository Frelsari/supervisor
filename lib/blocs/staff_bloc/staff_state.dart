part of 'staff_bloc.dart';

abstract class StaffState extends Equatable {
  const StaffState();
}

class ShowStaffState extends StaffState {
  final List<Map> staffList;

  ShowStaffState({this.staffList}): assert(staffList != null);

  @override
  List<Object> get props => [this.staffList];
}

class NoStaffState extends StaffState {
  @override
  List<Object> get props => [];
}
