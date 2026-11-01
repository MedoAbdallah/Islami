abstract interface class QiblaRepository {
  Stream<double?>? watchHeadings({
    required double latitude,
    required double longitude,
  });
}
