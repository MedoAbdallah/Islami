import 'package:equatable/equatable.dart';
import 'package:islami/core/model/hadeth.dart';

enum HadithStatus { initial, loading, loaded, failure }

class HadithState extends Equatable {
  const HadithState({
    this.status = HadithStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final HadithStatus status;
  final List<Hadeth> items;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, items, errorMessage];
}
