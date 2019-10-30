
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
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart'as calculate;

List<double> distancias= List<double>();
List<String> nombres= List<String>();
List<Mapa> mapas = List<Mapa>();
void main() => runApp(NearestCourt());
 int meter=0;
class NearestCourt extends StatelessWidget {

 
  NearestCourt({Key key}): super(key:key);
  double rest;

  // Variables para el control de la ubicacion del mapa e iconos
  LatLng centro =  new LatLng(6.2322794, -75.6172466);
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
    //print("Si corrio");
    //print("Loading : $loading");
    //print(lat);
    //print(lng);
//final Uint8List markerIcon = await getBytesFromAsset('iconos/cancha_opt.png', 100);
  }
// METODO QUE ENVIA LA INFORMACION DE LA CANCHA Y LA CREA
  
//METODO ENCARGADO DE CREAR LOS MARKERS CON EL ICONO DE CANCHA EN EL MAPA
  getCourt() async {
    //print("si cogio el metodo");
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
  }

  calculateDistances(List<Mapa> canchas){


     final calculate.Distance distance = new calculate.Distance();
     
    
    canchas.forEach((c){
      rest = distance.as(calculate.LengthUnit.Kilometer,
      new calculate.LatLng(prefix0.lat, prefix0.lng),
      new calculate.LatLng(c.latitude, c.longitude));
    distancias.add(rest);
    nombres.add(c.name);








    });
   
  }


  @override
  Widget build(BuildContext context) {
    getCourt();
   getLocation();
   calculateDistances(mapas);
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (loading == false) {
            return ListView.builder(
              itemCount: distancias.length,
              itemBuilder: (context,index){
                title: Text(nombres[index]);
              },
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


