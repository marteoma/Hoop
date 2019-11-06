import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:flutter/material.dart';


Widget btCancha( BuildContext context ,bool show, String c)  {
  return Visibility(
      visible: show,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SolidBottomSheet(
        headerBar: Container(
          color: Colors.deepOrange[200],
          height: 50,
          child: Center(
            child: Text("Informacion de la cancha"),
          ),
        ),
        body: Text(c),
      );

        },
        
      ) 
      );
}
