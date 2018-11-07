import 'package:flutter/material.dart';
import 'package:gas_app/map_requests.dart';

class NearbyGasPrices extends StatefulWidget {
  @override
  createState() => NearbyGasPricesState();
}

class NearbyGasPricesState extends State<NearbyGasPrices> {
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Gas Stations'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: FutureBuilder(
        future: getGasStations(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press refresh to load');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: Text('Loading...'));
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return GasPriceCard(snapshot.data[index]);
                },
              );
          }
        },
      ),
    );
  }
}

class GasPriceCard extends StatelessWidget {
  final GasStationEntry station;

  GasPriceCard(this.station);

  @override
  build(BuildContext context) {
    return Container(
      height: 70.0,
      margin: EdgeInsets.fromLTRB(10.0, 2.5, 10.0, 2.5),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.grey[100],
        child: Row(
          children: <Widget>[
            const Icon(Icons.local_gas_station, color: Colors.blueGrey),
            Text(this.station.name, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
