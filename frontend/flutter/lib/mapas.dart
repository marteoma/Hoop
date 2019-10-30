
import 'dart:convert';

class Mapa {
   int id;
   String name;
  double latitude;
   double longitude;
  String type;

  Mapa({this.id, this.name, this.latitude,this.longitude,this.type});

  factory Mapa.fromJson(Map<String, dynamic> json) {
    return Mapa(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude']as double,
      type: json['type'] as String
    );
  }


  List<Mapa> parseMapas(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Mapa>((json) => Mapa.fromJson(json)).toList();
}

}