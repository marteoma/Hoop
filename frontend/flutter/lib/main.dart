import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:search_map_place/search_map_place.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'bt_cancha.dart';
import 'ImagePicker.dart';
import 'CourtCreator.dart';

void main() => runApp(PrincipalPage());

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GoogleMapController mapController;
  Completer<GoogleMapController> _mapController = Completer();
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

var lng, lat;
  var loading = true;
  var tapped;
  Uint8List markerIcon;

class PrincipalPage extends StatelessWidget {
  
  

  
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
    //print("Si corrio");
    //print("Loading : $loading");
    //print(lat);
    //print(lng);
//final Uint8List markerIcon = await getBytesFromAsset('iconos/cancha_opt.png', 100);
  }

  void _showModal(BuildContext context) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.star),
                title: Text("Favorite"),
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {}

  Column _buildBottonNavigationMethod() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text('Add as favourite'),
        )
      ],
    );
  }

  void showSlideupView(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return new Container(
            child: new GestureDetector(
              onTap: () => Navigator.pop(context),
              child: new Text("Click me to close this non-modal bottom sheet"),
            ),
          );
        });
  }

  void addCourts(BuildContext context) {
    getLocation();
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
         // print("si cogio");
          _showModal(context);
        },
        consumeTapEvents: tapped);

    markers[_marker.markerId] = _marker;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    addCourts(context);
    print(tapped);

    return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (loading == false) {
            return new MaterialApp(
              home: new  MainPage()
            );
          } else {
            print(snapshot.error);
            var location = new Location();
            location.requestService();
            loading = false;
            return new CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: new AppBar(
                  title: new Text("Hoop!"),
                ),
                //esto aqui es para ir a donde se agregan las canchas.
                drawer: Theme(
                  child:Drawer(
                  
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>  CourtCreator()));
                        },
                      )
                    ],
                  ),
                ), data: Theme.of(context).copyWith(
                  canvasColor: Colors.deepOrange[200],
                ), 
                ), 
                body: new Stack(
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
                          controller.animateCamera(CameraUpdate.newLatLngBounds(
                              geolocation.bounds, 0));
                        },
                      ),
                    ),
                  ],
                ),
              );
  }
}