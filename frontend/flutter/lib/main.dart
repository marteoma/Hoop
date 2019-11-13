import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/nearestCourt.dart';
import 'dart:async';
import 'package:search_map_place/search_map_place.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'bt_cancha.dart';
import 'mapas.dart';
import 'nearestCourt.dart';
import 'package:async_loader/async_loader.dart';
import 'CourtCreator.dart';
import 'Loading.dart';


class HomePage extends MaterialPageRoute {
  HomePage() : super(builder: (context) => new PrincipalPage());
}

void main() => runApp(PrincipalPage());
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

GoogleMapController mapController;
Completer<GoogleMapController> _mapController = Completer();
void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

var lng, lat;
bool showInfoCancha = false;
bool loading = true;
var tapped;


Uint8List markerIcon;
List<Mapa> canchas = List<Mapa>();
final GlobalKey<AsyncLoaderState> asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();
class PrincipalPage extends StatelessWidget {
  

  Future<List<Mapa>> getCourt() async {
    //print("si cogio el metodo");
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = "https://hoop-back.herokuapp.com/api/v1/courts/";
    // String json ='{"name":'+nameCourt+',"latitude":'+"$lat"+',"longitude":'+"$long"+',"type":'+type+'}';
    
    Response response = await get(url, headers: headers);
    //print(response.statusCode);
    final json = jsonDecode(response.body);
    //print(json[0]['latitude']);

    json.forEach((j) {
      Mapa m = new Mapa();
      //print(j);
      m.id = j['id'];
      m.latitude = j['latitude'];
      m.longitude = j['longitude'];
      m.name = j['name'];
      m.type = j['type'];
      canchas.add(m);
    });
    // print(canchas[0].id);
  return canchas;
  }

  Future<List<Mapa>> getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();

    location.onLocationChanged().listen((LocationData currentLocation) {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
    lat = currentLocation.latitude;
    lng = currentLocation.longitude;

    return getCourt();
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
                image: new AssetImage('assets/sad.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        new Text("oh oh algo salio mal =("),
        new FlatButton(
            color: Colors.red,
            child: new Text(
              "Intentar de nuevo",
              style: TextStyle(color: Colors.blue,),
            ),
            onPressed: () => asyncLoaderState.currentState.reloadState())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var _asyncLoader = new AsyncLoader(
      key: asyncLoaderState,
      initState: () async => await getLocation(),
      renderLoad: () => Loading(),
      renderError: ([error]) => getNoConnectionWidget(),
      renderSuccess: ({data}) => MainPage(canchas: data),
    );

    return new MaterialApp(
      theme: ThemeData(
                  hintColor: Color(0xFFC0F0E8),
                  primaryColor: Colors.deepOrangeAccent[400],
                  canvasColor: Colors.white,
                  fontFamily: "Montserrat",
                ),
      home: _asyncLoader,
      
    );
  }
}

class MainPage extends StatelessWidget {
  List<Mapa> canchas;
 static String name = "holis";
 final GlobalKey<ScaffoldState> _scaffoldKey = new  GlobalKey<ScaffoldState>();
 

  MainPage({Key key, @required this.canchas}) : super(key: key);

  void addCourts(BuildContext context, List<Mapa> courts) {
    
    courts.forEach((c) {
      //print(c);
      var uuid = new Uuid();
      var id = uuid.v4();
      Marker _marker = new Marker(
          icon: BitmapDescriptor.fromAsset("assets/court.png"),
          markerId: MarkerId(id),
          position: LatLng(c.latitude, c.longitude),
          infoWindow: InfoWindow(title: c.name, snippet: c.type),
          onTap: () {
            //print("si cogio");
            showInfoCancha = !showInfoCancha;
            print(showInfoCancha);
            name = c.name;
            
          },
          consumeTapEvents: tapped);

      markers[_marker.markerId] = _marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    //print(canchas);
    addCourts(context, canchas);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Hoop!"),
        key: _scaffoldKey,
      ),

      //esto aqui es para ir a donde se agregan las canchas.
      drawer: Theme(
        child: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Carlos Asprilla"),
                accountEmail: Text("Point Guard Puntaje : 70"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/basketball-player.png"),
                ),
              ),
              ListTile(
                title: Text("Agregar Cancha"),
                trailing: Icon(Icons.add),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CourtCreator()));
                },
              ),
              ListTile(
                title: Text("Ver Canchas Cercanas"),
                trailing: Icon(Icons.map),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => NearestCourt()));
                },
              )
            ],
          ),
        ),
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
      ),
      bottomSheet: btCancha(context, showInfoCancha, name),
      body: Stack(
        children: <Widget>[
          Container(
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: Set<Marker>.of(markers.values),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15.0,
              ),
              onMapCreated: _onMapCreated,
            ),
          ),
          Positioned(
            top: 55,
            left: 10,
            // width: MediaQuery.of(context).size.width * 0.9,
            child: SearchMapPlaceWidget(
              apiKey: "AIzaSyCcmqji4cShofuKKZMpmX6aVXKZCMeP6vM",
              location: LatLng(lat, lng),
              radius: 30000,
              onSelected: (place) async {
                final geolocation = await place.geolocation;

                final GoogleMapController controller =
                    await _mapController.future;

                controller.animateCamera(
                    CameraUpdate.newLatLng(geolocation.coordinates));
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
              },
            ),
          ),
        ],
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
