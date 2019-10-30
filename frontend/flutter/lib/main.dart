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

import 'CourtCreator.dart';

void main() => runApp(PrincipalPage());
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

GoogleMapController mapController;
Completer<GoogleMapController> _mapController = Completer();
void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}
  var lng, lat;
  bool showInfoCancha= false;
  bool loading = true;
  var tapped;
 
Uint8List markerIcon;
List<Mapa> mapas = List<Mapa>();

class PrincipalPage extends StatefulWidget {


 @override
  State<StatefulWidget> createState() {
    

        return PrincipalPagestate();
  }
}
class PrincipalPagestate extends State<PrincipalPage> {



  
   Future getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();
    

    location.onLocationChanged().listen((LocationData currentLocation) {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
    lat = currentLocation.latitude;
    lng = currentLocation.longitude;
    

    loading= false;
  }
  
void initState(){
  super.initState();
  getLocation();
loading= false;

}

getCourt() async {
    print("si cogio el metodo");
    Map<String, String> headers = {"Content-type": "application/json"};
    String url= "https://hoop-back.herokuapp.com/api/v1/courts/";
   // String json ='{"name":'+nameCourt+',"latitude":'+"$lat"+',"longitude":'+"$long"+',"type":'+type+'}';
    
    Response response = await get(url,headers:headers);
    //print(response.statusCode);
    final  json = jsonDecode(response.body);
    //print(json[0]['latitude']);
    
    json.forEach((j){
      Mapa m = new Mapa();
      //print(j);
      m.id = j['id'];
      m.latitude= j['latitude'];
      m.longitude= j['longitude'];
      m.name = j['name'];
      m.type=j['type'];
      mapas.add(m);

    });

    
    //print(mapas[0].id);
  }
  @override
  Widget build(BuildContext context) {
   
     
      getCourt();

   

    return  Container(
      alignment: Alignment.center,
      child:  FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (loading == false) {
            
            return  MaterialApp(home:  MainPage());
          } else {
            print(snapshot.error);
            var location = new Location();
            location.requestService();
          
            return  CircularProgressIndicator();
            
          }
        },
      ),
    );
  }

 
  
  


  
}
  


 




class MainPage extends StatelessWidget {

  void addCourts(BuildContext context, List<Mapa> canchas) {
    

  canchas.forEach((c){
    var uuid = new Uuid();
    var id = uuid.v4();
Marker _marker = new Marker(
        icon: BitmapDescriptor.fromAsset("assets/court.png"),
        markerId: MarkerId(id),
        position: LatLng(c.latitude, c.longitude),
        infoWindow: InfoWindow(
            title: c.name,
            snippet: c.type),
        onTap: () {
          print("si cogio");
         showInfoCancha= !showInfoCancha;
         print(showInfoCancha);
        },
        consumeTapEvents: tapped);

    markers[_marker.markerId] = _marker;

  });
    
  }

  @override
  Widget build(BuildContext context) {
    addCourts(context,mapas);
    return  Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar:  AppBar(
        title:  Text("Hoop!"),
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
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.blue
                          : Colors.white,
                  child: Text(
                    "C",
                    style: TextStyle(fontSize: 40.0),
                  ),
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
          canvasColor: Colors.deepOrange[200],
        ),
      ),
      bottomSheet: btCancha(showInfoCancha),
      body:  Stack(
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
