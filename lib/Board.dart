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

  final double border_size = 15.0;

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

  Widget buildBoard(double container_width) {
    bool hasCoveredCell = false;
    final double box_width = container_width/rows -5.0;

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
                box_width: box_width,
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
            box_width: box_width,
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
    return  Container(

        decoration: _buildBoxDecoration(2.0, [600,600,100,600], 500, BoxShadow(
          color: Colors.grey[700],
          blurRadius: 4.0,
        )),

        child: Column(
          children: boardRow,
        ), // Column

    ); // Container
  }


  @override
  Widget build(BuildContext context) {
    // Get screen size in order to make board adapt to different phones
    final double screen_width = MediaQuery.of(context).size.width;
    final double screen_height = MediaQuery.of(context).size.height;
    int minesLeft = numOfMines-minesFound;
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mine Sweeper'),
        actions: <Widget>[],
      ), // Appbar
      body: new Container(
        height: screen_height,
        width: screen_width,
        color: Colors.grey[600],
        child: Column(
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
              Container(
                height: screen_width,
                padding: EdgeInsets.all(border_size),
                decoration: _buildBoxDecoration(2.0, [600,600,600], 400, BoxShadow(
                color: Colors.black,
                blurRadius: 2.0,
              )),

                child: buildBoard(screen_width-border_size*2),
              ), // Padding

            ]
        ),// Center
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
Widget buildTile(Widget child, double box_width) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: box_width,
    width: box_width,
    decoration: _buildBoxDecoration(2.0, [100,500,500, 100], 400, BoxShadow()),
    margin: EdgeInsets.all(2.0),

    child: child,
  );
}

Widget buildInnerTile2(Widget child, double box_width) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: box_width,
    width: box_width,
    decoration: _buildBoxDecoration(2.0, [500,100,100, 500], 400, BoxShadow()),

    margin: EdgeInsets.all(2.0),

    child: child,
  );
}


class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;
  final double box_width;

  CoveredMineTile({this.flagged, this.posX, this.posY, this.box_width});

  @override
  Widget build(BuildContext context) {

    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: box_width*(2/3),
      width: box_width*(2/3),
      color: Colors.grey[400],
      child: Container(
        padding: EdgeInsets.all(1.0),
        margin: EdgeInsets.all(2.0),
        height: box_width,
        width: box_width,

        child: RichText(
          text: TextSpan(
            text: flagged ? "\u2691" : "", // Symbol for flag
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ), // Text style
          ), // Text Span
        ),
      ),
    );
    return buildTile(innerTile, box_width);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state;
  final int count;
  final double box_width;
  OpenMineTile({this.state, this.count, this.box_width});

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
              color: textColor[count - 1],
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

    return Container(
        padding: EdgeInsets.all(1.0),
    height: box_width,
    width: box_width,
    decoration: _buildBoxDecoration(0.5, [500,100,100, 500], 400, BoxShadow()),

    margin: EdgeInsets.all(2.0),

    child: text,
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
