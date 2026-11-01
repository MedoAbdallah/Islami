import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/features/qibla/presentation/cubit/qibla_compass_cubit.dart';
import 'package:islami/features/qibla/presentation/cubit/qibla_compass_state.dart';
import 'package:islami/features/qibla/data/datasources/compass_data_source.dart';
import 'package:islami/features/qibla/data/repositories/qibla_repository_impl.dart';
import 'package:islami/features/qibla/domain/usecases/watch_compass_heading.dart';
import 'package:islami/features/qibla/presentation/widgets/qibla_compass_card.dart';

/// Inline Qibla compass for the Prayer Times tab.
class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    this.locationAvailable = true,
  });

  final double latitude;
  final double longitude;
  final String locationLabel;
  final bool locationAvailable;

  @override
  Widget build(BuildContext context) => BlocProvider(
    key: ValueKey((latitude, longitude)),
    create: (_) => QiblaCompassCubit(
      WatchCompassHeading(QiblaRepositoryImpl(CompassDataSource())),
      latitude: latitude,
      longitude: longitude,
    )..start(),
    child: BlocBuilder<QiblaCompassCubit, QiblaCompassState>(
      builder: (context, state) => QiblaCompassCard(
        latitude: latitude,
        longitude: longitude,
        locationLabel: locationLabel,
        heading: state.heading,
        locationAvailable: locationAvailable,
      ),
    ),
  );
}
