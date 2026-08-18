import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}


class AttendanceFailure extends Failure {
  const AttendanceFailure(super.message);
}

class LeaveFailure extends Failure {
  const LeaveFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
