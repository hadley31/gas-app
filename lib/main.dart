import 'package:gas_app/gas_charts.dart';
import 'package:gas_app/manage_data.dart';
import 'package:gas_app/settings_menu.dart';
import 'package:gas_app/nearby_stations.dart';

import 'package:flutter/material.dart';

void main() => runApp(GasApp());

class GasApp extends StatelessWidget {
  @override
  build(BuildContext context) {
    return MaterialApp(
      title: 'Gas App',
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColorBrightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.blueGrey,
        textSelectionHandleColor: Colors.blueGrey,
        toggleableActiveColor: Colors.blueGrey,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gas App'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ManageDataPage(),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  image: AssetImage('images/drawer_header_background.jpg'),
                ),
              ),
              child: Container(),
            ),
            ListTile(
              leading: Icon(Icons.local_gas_station, color: Colors.blueGrey[300]),
              title: const Text('Nearby Gas Stations', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => NearbyGasPrices()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart, color: Colors.blue),
              title: const Text('Charts', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => GasCharts()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blueGrey[300]),
              title: const Text('Settings', style: TextStyle(fontSize: 15.0)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsMenu()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
