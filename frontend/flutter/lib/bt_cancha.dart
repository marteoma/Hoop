import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:flutter/material.dart';

Widget btCancha(bool show) {
  return Visibility(
      visible: show,
      child: SolidBottomSheet(
        headerBar: Container(
          color: Colors.deepOrange[200],
          height: 50,
          child: Center(
            child: Text("Informacion de la cancha"),
          ),
        ),
        body: Text("Pulsa porfavor una cancha para ver la informacion de esta"),
      ));
}
