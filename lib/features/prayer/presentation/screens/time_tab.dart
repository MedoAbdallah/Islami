import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islami/core/common_widget/base_tob_body.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:islami/features/prayer/presentation/widgets/prayer_card.dart';
import 'package:islami/features/qibla/presentation/screens/qibla_compass_widget.dart';

class TimeTab extends StatelessWidget {
  const TimeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TimeTabContent();
  }
}

class _TimeTabContent extends StatefulWidget {
  const _TimeTabContent();

  @override
  State<_TimeTabContent> createState() => _TimeTabContentState();
}

class _TimeTabContentState extends State<_TimeTabContent> {
  PrayerCubit get _vm => context.read<PrayerCubit>();

  Future<void> _chooseCity() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.background,
      isScrollControlled: true,
      builder: (sheetContext) {
        final p = sheetContext.palette;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر الموقع',
                  style: TextStylesHelper.largeBodyTextStyle(sheetContext),
                ),
                ListTile(
                  leading: Icon(Icons.my_location_rounded, color: p.primary),
                  title: const Text('استخدام موقعي الحالي (GPS)'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _vm.setLocation(gps: true);
                  },
                ),
                Divider(color: p.onBackground.withValues(alpha: .24)),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * .45,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _vm.popularCities.length,
                    itemBuilder: (context, i) {
                      final city = _vm.popularCities[i];

                      return ListTile(
                        title: Text(city.nameAr),
                        subtitle: Text(city.nameEn),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _vm.setLocation(
                            gps: false,
                            selectedCityId: city.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerCubit, PrayerState>(
      builder: (context, state) {
        final p = context.palette;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: BaseTabBody(
            child: RefreshIndicator(
              color: p.primary,
              backgroundColor: p.background,
              onRefresh: _vm.loadPrayerTimes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مواقيت الصلاة',
                                style: TextStylesHelper.largeBodyTextStyle(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: _chooseCity,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: p.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _vm.locationLabel,
                                        style:
                                            TextStylesHelper.smallLabelTextStyle(
                                              context,
                                              textColor: p.onBackground
                                                  .withValues(alpha: .65),
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'تحديث الموقع والمواقيت',
                          onPressed: _vm.isLoading ? null : _vm.loadPrayerTimes,
                          icon: _vm.isLoading
                              ? SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: p.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location_rounded,
                                  color: p.primary,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PrayerCard(
                      now: _vm.now,
                      prayers: _vm.today,
                      next: _vm.next,
                      current: _vm.current,
                      remaining: _vm.remaining,
                    ),
                    QiblaCompassWidget(
                      latitude: _vm.coordinates.latitude,
                      longitude: _vm.coordinates.longitude,
                      locationLabel: _vm.locationLabel,
                      locationAvailable:
                          !_vm.isLoading && _vm.locationError == null,
                    ),
                    if (_vm.loadError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _LoadError(
                          message: _vm.loadError!,
                          button:
                              _vm.locationError?.settingsButtonLabel ??
                              'إعادة المحاولة',
                          onRetry: () async {
                            if (_vm.locationError?.openAppSettings == true) {
                              await Geolocator.openAppSettings();
                            } else if (_vm
                                    .locationError
                                    ?.openLocationSettings ==
                                true) {
                              await Geolocator.openLocationSettings();
                            } else {
                              await _vm.loadPrayerTimes();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.button,
    required this.onRetry,
  });

  final String message;
  final String button;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.primary.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: p.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: Text(button)),
        ],
      ),
    );
  }
}
