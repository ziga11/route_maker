import 'package:flutter/material.dart';
import 'package:route_maker/home.dart';
import 'package:route_maker/map.dart';
import 'package:route_maker/profile.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        backgroundColor: ModalRoute.of(context)!.settings.name == "Home"
            ? Colors.lightBlueAccent
            : Colors.indigoAccent.shade700,
        child: TextButton(
          child: const Column(
            children: [Icon(Icons.home), Text("Home")],
          ),
          onPressed: () {
            MaterialPageRoute(
                builder: (context) => const Home(),
                settings: const RouteSettings(name: "Home"));
          },
        ),
      ),
      CircleAvatar(
        backgroundColor: ModalRoute.of(context)!.settings.name == "Map"
            ? Colors.lightBlueAccent
            : Colors.indigoAccent.shade700,
        child: TextButton(
          child: const Column(
            children: [Icon(Icons.map), Text("Map")],
          ),
          onPressed: () {
            MaterialPageRoute(
                builder: (context) => const Map(),
                settings: const RouteSettings(name: "Map"));
          },
        ),
      )
    ]);
  }
}
