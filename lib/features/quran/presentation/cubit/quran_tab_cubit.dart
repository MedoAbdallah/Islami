import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/model/sura.dart';
import '../../domain/usecases/add_recent_sura.dart';
import '../../domain/usecases/get_recent_suras.dart';
import '../../domain/usecases/get_suras.dart';
import 'quran_tab_state.dart';

class QuranTabCubit extends Cubit<QuranTabState> {
  QuranTabCubit({required GetSuras getSuras, required GetRecentSuras getRecentSuras,
    required AddRecentSura addRecentSura}) : _getSuras = getSuras,
      _getRecentSuras = getRecentSuras, _addRecentSura = addRecentSura,
      super(const QuranTabState());

  final GetSuras _getSuras;
  final GetRecentSuras _getRecentSuras;
  final AddRecentSura _addRecentSura;

  Future<void> initialize() async {
    emit(state.copyWith(status: QuranTabStatus.loading, clearError: true));
    try {
      final suras = _getSuras();
      final recent = await _getRecentSuras();
      emit(state.copyWith(allSuras: suras, visibleSuras: suras,
        recentSuras: recent, status: QuranTabStatus.ready));
    } catch (error) {
      emit(state.copyWith(status: QuranTabStatus.failure, errorMessage: error.toString()));
    }
  }

  void search(String value) {
    final query = value.trim();
    final normalized = query.toLowerCase();
    final visible = query.isEmpty ? state.allSuras : state.allSuras.where((sura) =>
      sura.nameAr.contains(query) || sura.nameEn.toLowerCase().contains(normalized)).toList();
    emit(state.copyWith(query: value, visibleSuras: visible));
  }

  Future<void> addToRecent(Sura sura) async {
    try {
      await _addRecentSura(sura);
      emit(state.copyWith(recentSuras: await _getRecentSuras()));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
