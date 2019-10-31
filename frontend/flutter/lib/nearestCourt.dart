import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:map/main.dart' as prefix0;
import 'mapas.dart';
import 'package:latlong/latlong.dart' as calculate;
import 'package:async_loader/async_loader.dart';
import 'main.dart';

List<double> distancias = List<double>();
List<String> nombres = List<String>();
List<Mapa> mapas = List<Mapa>();
void main() => runApp(NearestCourt());
int meter = 0;

class NearestCourt extends StatelessWidget {
  final GlobalKey<AsyncLoaderState> asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();
  NearestCourt({Key key}) : super(key: key);
  double rest;

  // Variables para el control de la ubicacion del mapa e iconos
  LatLng centro = new LatLng(6.2322794, -75.6172466);
  var lng, lat;
  var loading = true;
  var tapped;
  String valueofdisctane;
  Uint8List markerIcon;
  Future getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();

    location.onLocationChanged().listen((LocationData currentLocation) {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
    lat = currentLocation.latitude;
    lng = currentLocation.longitude;
    loading = false;
  }

  bool back = false;
  void goback(BuildContext context) {
    mapas.clear();
    distancias.clear();
    nombres.clear();

    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PrincipalPage()));
  }

  calculateDistances(List<Mapa> canchas) {
    final calculate.Distance distance = new calculate.Distance();

    canchas.forEach((c) {
      rest = distance(new calculate.LatLng(prefix0.lat, prefix0.lng),
          new calculate.LatLng(c.latitude, c.longitude));
      distancias.add(rest);
      nombres.add(c.name);
    });
    print(prefix0.lng);
  }

  Future<List<Mapa>> getCourt() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = "https://hoop-back.herokuapp.com/api/v1/courts/";

    Response response = await get(url, headers: headers);

    final json = jsonDecode(response.body);

    json.forEach((j) {
      Mapa m = new Mapa();
      //print(j);
      m.id = j['id'];
      m.latitude = j['latitude'];
      m.longitude = j['longitude'];
      m.name = j['name'];
      m.type = j['type'];
      mapas.add(m);
    });
    calculateDistances(mapas);
  }

  Widget getCourtList(List<Mapa> mapas) {
    return ListView.builder(
      itemCount: distancias.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: 44,
              maxWidth: 64,
              maxHeight: 64,
            ),
            child: Image.asset("assets/court.png", fit: BoxFit.cover),
          ),
          title: Text(nombres[index]),
          subtitle: Text("Se encuentra a una distancia de " +
              distancias[index].toString() +
              " Metros"),
        );
      },
    );
  }

  Widget getNoConnectionWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60.0,
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/court.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        new Text("oh oh algo salio mal =("),
        new FlatButton(
            color: Colors.red,
            child: new Text(
              "Retry",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => asyncLoaderState.currentState.reloadState())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var _asyncLoader = new AsyncLoader(
      key: asyncLoaderState,
      initState: () async => await getCourt(),
      renderLoad: () => Center(child: new CircularProgressIndicator()),
      renderError: ([error]) => getNoConnectionWidget(),
      renderSuccess: ({data}) => getCourtList(data),
    );
    return WillPopScope(
      onWillPop: (){
        goback(context);
      },
      child: Scaffold(
        appBar: AppBar(title: buildAppBarTitle('Hoop!')),
        body: Center(child: _asyncLoader),
      ),
    );
  }
}

buildAppBarTitle(String title) {
  return new Padding(
    padding: new EdgeInsets.all(10.0),
    child: new Text(title),
  );
}
