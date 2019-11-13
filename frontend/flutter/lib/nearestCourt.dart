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
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:progress_indicators/progress_indicators.dart';

List<double> distancias = List<double>();
List<String> nombres = List<String>();
List<Mapa> mapas = List<Mapa>();
List<LatLng> geo = List<LatLng>();
void main() => runApp(NearestCourt());
int meter = 0;

class NearestCourt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NearestCourtState();
  }
}

class NearestCourtState extends State<NearestCourt> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    goback();

    return true;
  }

  GlobalKey<ScaffoldState> nearestkey;
  final GlobalKey<AsyncLoaderState> asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

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
  Future<bool> goback() {
    mapas.clear();
    distancias.clear();
    nombres.clear();

    Navigator.pop(context);
    //Navigator.of(context)
    //  .push(new prefix0.HomePage());
  }

  calculateDistances(List<Mapa> canchas) {
    final calculate.Distance distance = new calculate.Distance();

    canchas.forEach((c) {
      rest = distance(new calculate.LatLng(prefix0.lat, prefix0.lng),
          new calculate.LatLng(c.latitude, c.longitude));
      distancias.add(rest);
      nombres.add(c.name);
      geo.add(LatLng(c.latitude, c.longitude));
    });
    //print(prefix0.lng);
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

  void showMessage(BuildContext context, int index) async {
    showDialog(
        context: context,
        builder: (_) => AssetGiffyDialog(
              onlyOkButton: true,
              image: Image(image: AssetImage("assets/map.gif")),
              title: Text(
                'No sabes donde queda la cancha!?',
                style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              description: Text(
                "Tranquilo al presionar en cualquiera de las canchas , automaticamente te enviara a google maps!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
                textScaleFactor: 1.1,
              ),
              entryAnimation: EntryAnimation.RIGHT,
              onOkButtonPressed: () {
                //Navigator.of(context).pop();
                LatLng cord = geo[index];
                MapUtils.openMap(cord.latitude, cord.longitude);
              },
            ));
  }

  Widget getCourtList(List<Mapa> mapas, BuildContext context) {
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
              (distancias[index] / 1000).toStringAsFixed(1) +
              " Kilometros"),
          onTap: () {
            //showMessage(context, index);
            //print(geo);
            //double lat = mapas[index].latitude;
            //  double lng = mapas[index].longitude;
            showMessage(context, index);
          },
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
      renderLoad: () => Center(
          child: HeartbeatProgressIndicator(
        child: Image.asset(
          "assets/ball.png",
          height: 128,
          width: 128,
        ),
      )),
      renderError: ([error]) => getNoConnectionWidget(),
      renderSuccess: ({data}) => getCourtList(data, context),
    );
    return WillPopScope(
      onWillPop: goback,
      child: Scaffold(
        key: nearestkey,
        appBar: AppBar(title: buildAppBarTitle('Hoop!')),
        body: Center(child: _asyncLoader),
      ),
    );
  }
}

class MapUtils {
  static openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
