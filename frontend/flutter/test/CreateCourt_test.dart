import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:map/main.dart';
import 'package:http/http.dart';
import 'package:map/CourtCreator2.dart';
import 'package:mockito/mockito.dart';


createCourt(String nameCourt,String type,LatLng ubicacion) async {
    print("si cogio el metodo");
    double lat= ubicacion.latitude;
    double long= ubicacion.longitude;
    Map<String, String> headers = {"Content-type": "application/json"};
    String url= "https://hoop-back.herokuapp.com/api/v1/courts/";
   // String json ='{"name":'+nameCourt+',"latitude":'+"$lat"+',"longitude":'+"$long"+',"type":'+type+'}';
    String json= '{"name": "$nameCourt","latitude": $lat,"longitude": $long,"type": "$type"}';
    print(json);
    Response response = await post(url,headers:headers,body:json);
    print(response.statusCode);
    print(response.body);
    return response.body.toString();
  }


main() {

    test('Probando si la cancha agrega exitosamente usando un mock de lo que hay que agregar en el metodo', () async {
     

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
    

      expect(await createCourt("ultima prueba","3x3",LatLng(6.2300994, -75.6037806)), equalsIgnoringWhitespace('{"id":14,"name":"ultima prueba","latitude":6.2300994,"longitude":-75.6037806,"type":"3x3"}'));
    });

}





