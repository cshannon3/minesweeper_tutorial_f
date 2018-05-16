import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

class TopBar extends StatefulWidget {


  final Function() onReset;
  final bool wonGame;
  final bool alive;
  final int minesLeft;
  final int timeElapsed;

  TopBar({
    this.onReset,
    this.wonGame,
    this.alive,
    this.minesLeft,
  this.timeElapsed});
  @override
  _TopBarState createState() => new _TopBarState();
}

class _TopBarState extends State<TopBar> {

  @override
  Widget build(BuildContext context) {

    return new Container(
      decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 2.0, color: Colors.grey[600]),
            right: BorderSide(width: 2.0, color: Colors.grey[600]),
            bottom: BorderSide(width: 2.0, color: Colors.grey[100]),
            top: BorderSide(width: 2.0, color: Colors.grey[600]),
          ),
          color: Colors.grey[400],
          boxShadow: [BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
          )]
      ), // Box DEc

      padding: EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0, bottom: 10.0),
    child: Container(
    height: 80.0,
    decoration: BoxDecoration(
    border: Border(
    left: BorderSide(width: 2.0, color: Colors.grey[600]),
    right: BorderSide(width: 2.0, color: Colors.grey[600]),
    bottom: BorderSide(width: 2.0, color: Colors.grey[100]),
    top: BorderSide(width: 2.0, color: Colors.grey[600]),
    ),
    color: Colors.grey[400],
    boxShadow: [BoxShadow(
    color: Colors.black,
    blurRadius: 2.0,
    )]
    ), // Box DEc
      child: Row(

        children: [
          // Mines Left
          Container(
            width: 100.0,
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
            width: 120.0,
            padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
            child:  new Center(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.grey[600]),
                      color: Colors.grey[400],
                      boxShadow: [BoxShadow(
                        color: Colors.black,
                        blurRadius: 2.0,
                      )]
                  ), // Box DEc
                  width: 60.0,
                  padding: EdgeInsets.all(5.0),
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
                ) // Container
            ), // Center
          ), //Container
          Expanded(
            child: Container(
              width: 100.0,
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
            ), // Container
          ), // Expanded



        ], // Row
      ), // Row

    ) // Container
    );
  }
}
