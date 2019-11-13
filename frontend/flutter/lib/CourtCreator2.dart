import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'ImagePicker.dart';
import 'main.dart';
import 'package:http/http.dart';

void main() => runApp(CourtCreator2(
      nombreCancha: null,
      posicionSeleccionada: null,
    ));
var mode;
const modos = ["3x3", "4x4", "5x5"];

class CourtCreator2 extends StatelessWidget {
  //Constructor que recibe parametros de CourtCreator para completar la informacion para el proceso de
  // creacion de una cancha

  final LatLng posicionSeleccionada;
  final String nombreCancha;
  CourtCreator2(
      {Key key,
      @required this.posicionSeleccionada,
      @required this.nombreCancha})
      : super(key: key);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GoogleMapController mapController;
  TextEditingController inputController = new TextEditingController();

  // Variables para el control de la ubicacion del mapa e iconos
  LatLng centro = LatLng(6.2300994, -75.6037806);
  var lng, lat;
  var loading = true;
  var tapped;
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
    print("Si corrio");
    print("Loading : $loading");
    print(lat);
    print(lng);
//final Uint8List markerIcon = await getBytesFromAsset('iconos/cancha_opt.png', 100);
  }

// METODO QUE ENVIA LA INFORMACION DE LA CANCHA Y LA CREA
  createCourt(String nameCourt, String type, LatLng ubicacion) async {
    double lat = ubicacion.latitude;
    double long = ubicacion.longitude;
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = "https://hoop-back.herokuapp.com/api/v1/courts/";
    // String json ='{"name":'+nameCourt+',"latitude":'+"$lat"+',"longitude":'+"$long"+',"type":'+type+'}';
    String json =
        '{"name": "$nameCourt","latitude": $lat,"longitude": $long,"type": "$type"}';

    Response response = await post(url, headers: headers, body: json);
    print(response.statusCode);
  }

//METODO ENCARGADO DE CREAR LOS MARKERS CON EL ICONO DE CANCHA EN EL MAPA
  void addCourts(BuildContext context) {
    getLocation();
    var uuid = new Uuid();
    var id = "Add_court";

    Marker _marker = new Marker(
        icon: BitmapDescriptor.fromAsset("assets/cancha_opt.png"),
        markerId: MarkerId(id),
        draggable: true,
        position: LatLng(6.230178, -75.6038394),
        infoWindow: InfoWindow(
            title: "Cancha de baloncesto por defecto",
            snippet: 'Jmm ya vamos en algo almenos'),
        consumeTapEvents: tapped);

    markers[_marker.markerId] = _marker;
  }

  @override
  Widget build(BuildContext context) {
    print(posicionSeleccionada);
    print(nombreCancha);
    addCourts(context);
    return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (loading == false) {
            return new MaterialApp(
              theme: ThemeData(
                  hintColor: Color(0xFFC0F0E8),
                  primaryColor: Colors.deepOrangeAccent[400],
                  canvasColor: Colors.white,
                  fontFamily: "Montserrat",
                ),
              home: new Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: new AppBar(
                  title: new Text("Hoop!"),
                ),
                body: new Column(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Text(
                          ' Agregar Imagenes de la cancha *',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                          textScaleFactor: 1.3,
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(child: ImagePicker()),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(
                          ' Seleccione el modo de juego usual *',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                          textScaleFactor: 1.3,
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(child: bottomModePicker(context)),
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Finalizar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            icon: Icon(Icons.arrow_right),
                            color: Colors.deepOrange,
                            iconSize: 50,
                            onPressed: () {
                              createCourt(nombreCancha, modos[mode],
                                  posicionSeleccionada);
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PrincipalPage()));
                            }),
                      ],
                    )),
                  ],
                ),
              ),
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

Widget bottomModePicker(BuildContext context) {
  int _selectedItemIndex = 0;
  const double _kPickerSheetHeight = 216.0;
  const double _kPickerItemHeight = 32.0;
  final FixedExtentScrollController scrollController =
      new FixedExtentScrollController(initialItem: _selectedItemIndex);
  return new Container(
    height: _kPickerSheetHeight,
    color: CupertinoColors.white,
    child: new DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 22.0,
      ),
      child: new GestureDetector(
        // Blocks taps from propagating to the modal sheet and popping.
        onTap: () {
          Navigator.of(context).pop(_selectedItemIndex);
        },
        child: new SafeArea(
          child: new CupertinoPicker(
            scrollController: scrollController,
            itemExtent: _kPickerItemHeight,
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int index) {
//                  print(_selectedItemIndex);
//                  Navigator.of(context).pop(index);
              _selectedItemIndex = index;
              mode = index;
            },
            children: new List<Widget>.generate(modos.length, (int index) {
              return new Center(
                child: new Text(modos[index]),
              );
            }),
          ),
        ),
      ),
    ),
  );
}
