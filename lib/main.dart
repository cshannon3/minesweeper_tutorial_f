

import 'package:flutter/material.dart';
import 'Board.dart';

void main() => runApp(new MineSweeper());

class MineSweeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Mine Sweeper",
      home: Board(),
    );
  }
}

