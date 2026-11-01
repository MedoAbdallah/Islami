import 'package:equatable/equatable.dart';
import 'package:islami/core/model/sura.dart';

class QuranTabState extends Equatable {
  const QuranTabState({
    this.allSuras = const [],
    this.visibleSuras = const [],
    this.recentSuras = const [],
    this.query = '',
    this.status = QuranTabStatus.initial,
    this.errorMessage,
  });

  final List<Sura> allSuras;
  final List<Sura> visibleSuras;
  final List<Sura> recentSuras;
  final String query;
  final QuranTabStatus status;
  final String? errorMessage;
  bool get isSearching => query.trim().isNotEmpty;

  QuranTabState copyWith({List<Sura>? allSuras, List<Sura>? visibleSuras,
    List<Sura>? recentSuras, String? query, QuranTabStatus? status,
    String? errorMessage, bool clearError = false}) => QuranTabState(
      allSuras: allSuras ?? this.allSuras,
      visibleSuras: visibleSuras ?? this.visibleSuras,
      recentSuras: recentSuras ?? this.recentSuras,
      query: query ?? this.query,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );

  @override
  List<Object?> get props => [allSuras, visibleSuras, recentSuras, query, status, errorMessage];
}

enum QuranTabStatus { initial, loading, ready, failure }
