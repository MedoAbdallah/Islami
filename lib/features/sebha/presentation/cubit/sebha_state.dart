import 'package:equatable/equatable.dart';

class SebhaState extends Equatable {
  const SebhaState({this.counter = 0, this.zekrIndex = 0});
  final int counter;
  final int zekrIndex;
  @override
  List<Object> get props => [counter, zekrIndex];
}
