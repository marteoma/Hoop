import 'dart:typed_data';
import 'package:map/CourtCreator.dart' as prefix0;
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:search_map_place/search_map_place.dart';
import 'package:uuid/uuid.dart';

import 'bt_cancha.dart';

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
 
Uint8List markerIcon;


class PrincipalPage extends StatefulWidget {


 @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

        return PrincipalPagestate();
  }
}
class PrincipalPagestate extends State<PrincipalPage> {
 bool loading = true;
  var tapped;

  
   Future getLocation() async {
    final location = Location();
    var currentLocation = await location.getLocation();

    location.onLocationChanged().listen((LocationData currentLocation) {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
    lat = currentLocation.latitude;
    lng = currentLocation.longitude;
    setState(() { this.loading= false;});


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
     addCourts(context);
   

   

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

 
  
  

void initState(){
  super.initState();



}
  void addCourts(BuildContext context) {
    var uuid = new Uuid();
    var id = uuid.v4();

    Marker _marker = new Marker(
        icon: BitmapDescriptor.fromAsset("assets/cancha_opt.png"),
        markerId: MarkerId(id),
        position: LatLng(6.230178, -75.6038394),
        infoWindow: InfoWindow(
            title: "Cancha de baloncesto por defecto",
            snippet: 'Jmm ya vamos en algo almenos'),
        onTap: () {
         showInfoCancha= !showInfoCancha;
        },
        consumeTapEvents: tapped);

    markers[_marker.markerId] = _marker;
  }

}
  


 




class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
