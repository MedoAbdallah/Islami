import 'package:equatable/equatable.dart';

class QiblaCompassState extends Equatable {
  const QiblaCompassState({this.heading});
  final double? heading;
  @override
  List<Object?> get props => [heading];
}
