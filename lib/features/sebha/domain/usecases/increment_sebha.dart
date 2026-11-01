import '../entities/sebha_counter.dart';

class IncrementSebha {
  const IncrementSebha({this.targetCount = 33, this.numberOfAzkar = 3});
  final int targetCount;
  final int numberOfAzkar;

  ({SebhaCounter counter, bool roundCompleted}) call(SebhaCounter current) {
    final nextCount = current.count + 1;
    final completed = nextCount >= targetCount;
    return (
      counter: SebhaCounter(
        count: completed ? 0 : nextCount,
        zekrIndex: completed ? (current.zekrIndex + 1) % numberOfAzkar : current.zekrIndex,
      ),
      roundCompleted: completed,
    );
  }
}
