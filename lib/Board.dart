import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'TopBar.dart';
//import 'Tiles.dart';

enum TileState {
  covered,
  blown,
  open,
  flagged,
  revealed
}

class Board extends StatefulWidget {
  @override
  BoardState createState() => new BoardState();
}

class BoardState extends State<Board> {
  final int rows = 9;
  final int cols = 9;
  final int numOfMines = 11;

  List<List<TileState>> uiState;
  //tiles will hold true/false for mines at each spot
  List<List<bool>> tiles;

  bool alive;
  bool wonGame;
  int minesFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void resetBoard() {
    alive = true;
    wonGame = false;
    minesFound = 0;
    stopwatch.reset();
    timer?.cancel(); // cancel old timer if it exists
    //Start new timer
    timer = Timer.periodic(Duration(seconds:  1), (Timer timer){
      setState(() {
      });
    });
    uiState = new List<List<TileState>>.generate(rows, (row) {
      return new List<TileState>.filled(cols, TileState.covered);
    }); // List.generate
    // generate an initial board with no mines
    tiles = new List<List<bool>>.generate(rows, (row) {
      return new List<bool>.filled(cols, false);
    }); // List.generate
    Random random = new Random();
    int remainingMines = numOfMines;
    while (remainingMines > 0) {
      int pos = random.nextInt(rows*cols);
      int row = pos ~/ rows; // the ~/ is integer division so i guess it gets the floor of divided val
      int col = pos % cols;
      // Now check if there is a mine at that spot, if there isn't add one
      if(!tiles[row][col]){
        tiles[row][col] = true;
        remainingMines--;
      }
    }

  }

  @override
  void initState() {
    resetBoard();
    super.initState();
  }

  Widget buildBoard() {
    bool hasCoveredCell = false;

    List<Row> boardRow = <Row>[];
    for (int y = 0; y < rows; y++) {
      List<Widget> rowChildren = <Widget>[];
      for (int x = 0; x < cols; x++) {
        TileState state = uiState[y][x];
        int count = mineCount(x, y);
        if (!alive) {
          if (state != TileState.blown){
            //This is to set it up so it will show the other mines
            // When you lose the game
            state = tiles[y][x] ? TileState.revealed : state;
          }
        }
        if (state == TileState.covered || state == TileState.flagged) {
          rowChildren.add(GestureDetector(
            onLongPress: (){
              flag(x, y);
            },
            onTap: () {
              if (state == TileState.covered) {
                probe(x, y);
              }
            },
            child: Listener(
              child: CoveredMineTile(
                flagged: state == TileState.flagged,
                posX: x,
                posY: y,
              ),
            ), // Listener
          ), // Gesture Detector
          ); // rowChildren add
          if (state == TileState.covered){
            hasCoveredCell = true;
          }
        }else {
          rowChildren.add(OpenMineTile(
            state: state,
            count: count,
          ));
        }
      }
      boardRow.add(
          Row(
            children: rowChildren,
            mainAxisAlignment: MainAxisAlignment.center,
            key: ValueKey<int>(y), // allows  you to refer to a row
          )); // Row
    }
    if (!hasCoveredCell) {
      if((minesFound == numOfMines) && alive) {
        wonGame = true;
        //stopwatch.stop();
      }
    }
    return Container(
      height: 345.0,
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 2.0, color: Colors.grey[600]),
            right: BorderSide(width: 2.0, color: Colors.grey[600]),
            bottom: BorderSide(width: 2.0, color: Colors.grey[600]),
          ),
          color: Colors.grey[400],
          boxShadow: [BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
          )]

      ), // Box DEc
      child: Container(

        decoration: BoxDecoration(
            border: Border(
              left: BorderSide(width: 2.0, color: Colors.grey[600]),
              right: BorderSide(width: 2.0, color: Colors.grey[600]),
              bottom: BorderSide(width: 2.0, color: Colors.grey[100]),
              top: BorderSide(width: 2.0, color: Colors.grey[600]),
            ),
            color: Colors.grey[500],
            boxShadow: [BoxShadow(
              color: Colors.grey[700],
              blurRadius: 4.0,
            )]
        ), // Box DEc
        child: Column(
          children: boardRow,
        ), // Column
      ),
    ); // Container
  }


  @override
  Widget build(BuildContext context) {
    int minesLeft = numOfMines-minesFound;
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mine Sweeper'),
      ), // Appbar
      body: Container(
        color: Colors.grey[50],
        child: new Container(
          padding: EdgeInsets.all(33.0),
          color: Colors.grey[600],
          child: Center(
              child: Stack(
                  children: [
              TopBar(
                     wonGame: wonGame,
                     alive: alive,
                     minesLeft: minesLeft,
                     timeElapsed: timeElapsed,
                     onReset: () {
                       setState(() {
                         resetBoard();
                       });
                     },

              ),
                    Padding(
                      padding: EdgeInsets.only(top: 100.0, bottom: 40.0),
                      child: buildBoard(),
                    ), // Padding

                  ]
              )
          ),// Center
        ), // Container
      ),// Container
    ); // Scaffold
  }
  void probe(int x, int y){
    if (!alive) return;
    if (uiState[y][x] == TileState.flagged) return;
    setState(() {
      if (tiles[y][x]){
        uiState[y][x] = TileState.blown;

        alive = false;


        timer.cancel();
      } else {
        open(x,y);
        if (!stopwatch.isRunning) stopwatch.start();
      }
    });
  }
  void open(int x, int y) {
    // Want to open up a single tile if it has a number on it
    // If there are no bombs surrounding tile we open up the 'pocket'
    // surrounding it that doesn't have bombs around them
    if (!inBoard(x, y)){ return;}
    if (uiState[y][x] == TileState.open){ return;}
    if(uiState[y][x] == TileState.flagged){
      minesFound--;
    }
    uiState[y][x] = TileState.open;



    //print(mineCount(x, y));
    if (mineCount(x, y) > 0) return;
    // To open the area needed, we will recursively call open 8 times on all
    // of the surrounding tiles
    open(x-1, y);
    open(x+1, y);
    open(x, y-1);
    open(x, y+1);
    open(x-1, y-1);
    open(x-1, y+1);
    open(x+1, y-1);
    open(x+1, y+1);
  }
  void flag(int x, int y){
    if (!alive) return;
    setState(() {
      if (uiState[y][x] == TileState.flagged) {
        uiState[y][x] = TileState.covered;
        --minesFound;
      } else {
        uiState[y][x] = TileState.flagged;
        ++minesFound;
      }
    });
  }

  int mineCount(int x, int y){
    int count = 0;
    count += bombs(x-1, y);
    count += bombs(x+1, y);
    count += bombs(x, y+1);
    count += bombs(x, y-1);
    count += bombs(x-1, y-1);
    count += bombs(x+1, y-1);
    count += bombs(x-1, y+1);
    count += bombs(x+1, y+1);
    return count;
  }

  int bombs(int x, int y) {
    return ((inBoard(x, y) && tiles[y][x]) ? 1 : 0);
  }
  bool inBoard(int x, int y) {
    return (x >= 0 && x < cols && y >= 0 && y < rows);
  }
}

// Make inner and outer containers to add 3D like shape
Widget buildTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 30.0,
    width: 30.0,
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(width: 2.0, color: Colors.grey[100]),
        right: BorderSide(width: 3.0, color: Colors.grey[500]),
        bottom: BorderSide(width: 2.0, color: Colors.grey[500]),
        top: BorderSide(width: 2.0, color: Colors.grey[100]),
      ),
      color: Colors.grey[400],

    ), // Box DEc
    margin: EdgeInsets.all(2.0),

    child: child,
  );
}
Widget buildInnerTile2(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 30.0,
    width: 30.0,
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(width: 0.5, color: Colors.grey[500]),
        right: BorderSide(width: 0.5, color: Colors.grey[100]),
        bottom: BorderSide(width: 0.5, color: Colors.grey[100]),
        top: BorderSide(width: 0.5, color: Colors.grey[500]),
      ),
      color: Colors.grey[400],

    ), // Box DEc
    margin: EdgeInsets.all(2.0),

    child: child,
  );
}
Widget buildInnerTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: 30.0,
    width: 30.0,

    child: child,
  );
}class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;

  CoveredMineTile({this.flagged, this.posX, this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (flagged) {
      text = buildInnerTile(RichText(
        text: TextSpan(
          text: "\u2691", // Symbol for flag
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ), // Text style
        ), // Text Span
      ));
    }
    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[400],
      child: text,
    );
    return buildTile(innerTile);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state;
  final int count;
  OpenMineTile({this.state, this.count});

  final List textColor = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (state == TileState.open) {
      if (count != 0) {
        text = //buildInnerTile2(
        RichText(
          text: TextSpan(
            text: "$count", // Symbol for flag
            style: TextStyle(
              color: textColor[count -1],
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
              fontFamily: 'BebasNeue',
            ), // Text style
          ), // Text Span
          textAlign: TextAlign.center,
        );//); // Rich Text
      }
    }
    else {
      text = //buildInnerTile2(
      RichText(
        text: TextSpan(
          text: "\u2739", // Symbol for explosion
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ), // Text style
        ), // Text Span
        textAlign: TextAlign.center,
      );//); // Rich Text
    }

    return buildInnerTile2(text);
  }
}