part of 'staff_bloc.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();
}

class AddStaffEvent extends StaffEvent {
  final String email, password, displayName;

  const AddStaffEvent({
    this.email,
    this.password,
    this.displayName,
  })  : assert(email != null),
        assert(password != null),
        assert(displayName != null);

  @override
  List<Object> get props => [
        this.email,
        this.password,
        this.displayName,
      ];
}

class GetStaffEvent extends StaffEvent {
  @override
  List<Object> get props => [];
}

class ModifyStaffEvent extends StaffEvent {
  @override
  List<Object> get props => [];
}

class DeleteStaffEvent extends StaffEvent {
  final String deleteUid;

  DeleteStaffEvent({@required this.deleteUid}) : assert(deleteUid != null);

  @override
  List<Object> get props => [this.deleteUid];
}
