import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'dart:async';

import 'CourtCreator2.dart';

// variables
LatLng centro = LatLng(6.2300994, -75.6037806);
var lng, lat;
var loading = true;
var tapped;
// Metodos y variables para el manejo del mapa
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

GoogleMapController mapController;

void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}

// Metodo para el manejo del movimiento del marker
void _onMarkerMove(CameraPosition position) {
  //print(" si cogio la movida");
  centro = position.target;
  //print(position.target.longitude);
  Marker markerMoved = markers["Add_court"];
  markerMoved.copyWith(
      positionParam:
          LatLng(position.target.latitude, position.target.longitude));
  //print(markerMoved.position.latitude);
}

void main() => runApp(CourtCreator());

class CourtCreator extends StatelessWidget {
  // Variables para el control de la ubicacion del mapa e iconos

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

  void addCourts(BuildContext context) {
    getLocation();

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
    addCourts(context);
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (loading == false) {
            return MaterialApp(home: MyCustomForm());
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
  var modos = ["3X3", "4X4", "5X5"];
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

// CLASE QUE CONTIENE TODO PARA PODER ENVIAR Y CREAR EL MAPAAAA! HPTAAA!!!
// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Hoop!"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Text(
                  'Para indicar la ubicacion de la cancha porfavor deja presionado el indicador y luego muevelo hasta la posicion deseada ',
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 0.4),
                )),
            Expanded(
              flex: 3,
              child: GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  markers: Set<Marker>.of(markers.values),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: centro,
                    zoom: 15.0,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMove: ((position) => _onMarkerMove(position))),
            ),
            Expanded(
                flex: 1,
                child: Text(
                  'Ingrese el nombre de la cancha ',
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 0.5),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Nombre",
                  labelText: "Nombre  de cancha*"
                  
                ),
                
                controller: myController,
              ),
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "Siguiente",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: Icon(Icons.arrow_right),
                    color: Colors.deepOrange,
                    iconSize: 50,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CourtCreator2(
                                posicionSeleccionada: centro,
                                nombreCancha: myController.text,
                              )));
                    }),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
