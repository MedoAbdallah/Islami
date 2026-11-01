import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sebha_counter.dart';
import '../../domain/usecases/increment_sebha.dart';
import 'sebha_state.dart';

class SebhaCubit extends Cubit<SebhaState> {
  SebhaCubit() : super(const SebhaState());
  static const int targetCount = 33;
  static const List<String> azkar = ['سبحان الله', 'الحمد لله', 'الله أكبر'];
  final IncrementSebha _increment = const IncrementSebha();
  String get currentZekr => azkar[state.zekrIndex];

  bool increment() {
    final result = _increment(SebhaCounter(count: state.counter, zekrIndex: state.zekrIndex));
    emit(SebhaState(counter: result.counter.count, zekrIndex: result.counter.zekrIndex));
    return result.roundCompleted;
  }

  void reset() => emit(const SebhaState());
}
