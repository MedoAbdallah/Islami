import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_hadith.dart';
import 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  HadithCubit(this._getHadith) : super(const HadithState());
  final GetHadith _getHadith;

  Future<void> load() async {
    emit(const HadithState(status: HadithStatus.loading));
    try {
      emit(HadithState(status: HadithStatus.loaded, items: await _getHadith()));
    } catch (_) {
      emit(
        const HadithState(
          status: HadithStatus.failure,
          errorMessage: 'تعذر تحميل الأحاديث',
        ),
      );
    }
  }
}
