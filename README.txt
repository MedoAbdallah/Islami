Qibla interactive map update
===========================

This is a patch bundle for the Islami Flutter project. Copy the included paths
into the matching locations in your project, replacing matching files, then run:

    flutter pub get

No Google Maps API key is needed. The Qibla screen keeps the existing live
compass and location permission flow. It now shows your location, the Kaaba,
a great-circle route between them, and the distance to Makkah. Bearing and
route calculations are local and need no network. The map also appears under
the compact Qibla compass on the Prayer Times tab; that widget receives the
same coordinates loaded by PrayerService. The map and compass stay in the
Prayer Times tab. The shared qibla_math.dart calculations are local, and
PrayerService's existing Cairo coordinates remain the fallback when a GPS fix
times out.

Map connectivity and offline behavior
-------------------------------------
The displayed street map uses the standard OpenStreetMap raster tile service
at https://tile.openstreetmap.org. Tile images need an internet connection and
the map background will be blank or incomplete offline; compass, bearing,
route geometry, and distance continue to work. The app does not pre-download
or promise offline map tiles. OpenStreetMap's standard tile service explicitly
prohibits offline prefetch/download use and is best-effort without an SLA.

The code includes the required visible OpenStreetMap contributor attribution
and identifies the Flutter app as "islami" to the tile service. Review the
current tile usage policy before release. For a production or higher-volume
app, select a hosted tile provider whose terms match your expected use, or
self-host tiles; change the URL in qibla_map_widget.dart. Offline maps require
a provider/license that explicitly permits storing and serving offline tiles.

Files
-----
- pubspec.yaml: adds flutter_map and latlong2.
- lib/features/home/tabs/qibla_tab/qibla_math.dart: shared bearing, distance,
  and great-circle route calculations.
- lib/features/home/tabs/qibla_tab/qibla_map_widget.dart: interactive map,
  markers, route, distance, and attribution.
- lib/features/home/tabs/qibla_tab/qibla_compass_widget.dart: uses the shared
  Qibla bearing calculation and shows the map in the Prayer Times tab.
- AndroidManifest.xml and Info.plist: included for review; location and
  internet permissions were already present, so no changes were needed there.
