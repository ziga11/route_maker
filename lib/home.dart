import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sqllite.dart';
import 'route.dart' as Route;
import 'map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<List<Route.Route>>(
            future: RouteDB().getRoutes(false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No Routes found'));
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final entity = snapshot.data![index];
                    final gpx = GpxReader().fromString(entity.gpx);

                    final trackPoints = <LatLng>[];
                    if (gpx.trks.isNotEmpty) {
                      for (final track in gpx.trks) {
                        for (final segment in track.trksegs) {
                          for (final point in segment.trkpts) {
                            trackPoints.add(LatLng(point.lat!, point.lon!));
                          }
                        }
                      }
                    }

                    final polyline = Polyline(
                      points: trackPoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    );

                    return InkWell(
                        child: Column(
                          children: [
                            Title(
                              color: Colors.black87,
                              child: Text(entity.title),
                            ),
                            const Spacer(),
                            Text(entity.description),
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: trackPoints.isNotEmpty
                                    ? trackPoints.first
                                    : const LatLng(
                                        51.509364, -0.128928), // London
                                initialZoom: 9.2,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                PolylineLayer(
                                  polylines: [polyline],
                                ),
                                RichAttributionWidget(
                                  attributions: [
                                    TextSourceAttribution(
                                      'OpenStreetMap contributors',
                                      onTap: () => launchUrl(Uri.parse(
                                          'https://openstreetmap.org/copyright')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          MaterialPageRoute(builder: (_) => const Map());
                        });
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
