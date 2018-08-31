import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'Board.dart';

class TopBar extends StatefulWidget {


  final Function() onReset;
  final bool wonGame;
  final bool alive;
  final int minesLeft;
  final int timeElapsed;
  final double barheight;

  TopBar({
    this.barheight = 80.0,
    this.onReset,
    this.wonGame,
    this.alive,
    this.minesLeft,
  this.timeElapsed});
  @override
  _TopBarState createState() => new _TopBarState();
}

class _TopBarState extends State<TopBar> {

  final double padding = 5.0;

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    double bar_height = widget.barheight;
    return new Container(
      decoration: _buildBoxDecoration(2.0, [600,600,100,600], 400, BoxShadow(
        color: Colors.black,
        blurRadius: 2.0,
      )),

      padding: EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0, bottom: 10.0),
    child: Container(
    height: bar_height,
    decoration:  _buildBoxDecoration(2.0, [600,600,100,600], 400, BoxShadow(
      color: Colors.black,
      blurRadius: 2.0,
    )),
    // Box DEc
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          // Mines Left
          Container(
            width: screen_width/4,
            color: Colors.black,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: widget.minesLeft < 10 ?
                "00${widget.minesLeft}": "0${widget.minesLeft}",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 50.0,

                ), // Text style
              ), // Text Span
              textAlign: TextAlign.center,
            ), // Rich Text
          ), // Container
          // Face
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.grey[600]),
                color: Colors.grey[400],
                boxShadow: [BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                )]
            ), // Box DEc
            width: bar_height-2*padding,
            height: bar_height-2*padding,
            padding: EdgeInsets.only(top: padding, bottom: padding),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.wonGame ? Colors.green: widget.alive ? Colors.yellow : Colors.red,
                  border: Border.all(width: 2.0, color: Colors.black),


                ), // Box DEc

              ), // Container
              onTap: () =>
                widget.onReset(),

            ), // Inkwell
          ), //Container
          Container(
            width: screen_width/4,
            color: Colors.black,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: (widget.timeElapsed < 10) ?
                "00${widget.timeElapsed}":
                (widget.timeElapsed < 100)?
                "0${widget.timeElapsed}": "${widget.timeElapsed}",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 50.0,

                ), // Text style
              ), // Text Span
              textAlign: TextAlign.center,
            ), // Rich Text
          ),



        ], // Row
      ), // Row

    ) // Container
    );
  }
}

BoxDecoration _buildBoxDecoration(double width, List<int> greys, int colorgrey, BoxShadow boxshadow) {
  return BoxDecoration(
      border: Border(
        left: BorderSide(width: width, color: Colors.grey[greys[0]]),
        right: BorderSide(width: width, color: Colors.grey[greys[1]]),
        bottom: BorderSide(width: width, color: Colors.grey[greys[2]]),
        top: (greys.length<3) ? BorderSide(width: width, color: Colors.grey[greys[3]]):BorderSide(color: Colors.grey[colorgrey],),
      ),
      color: Colors.grey[colorgrey],
      boxShadow: [boxshadow]
  ); // Box DEc
}
