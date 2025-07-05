import 'package:flutter/material.dart';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class FlightTicket {
  bool displayFront;
  String originText;
  String destinationText;
  String path;

  FlightTicket({
    this.displayFront = true,
    required this.originText,
    required this.destinationText,
    required this.path,
  });

  void toggleDisplay() {
    displayFront = !displayFront;
  }
}

// quality: null is default, so no compression
typedef OnPickImageCallback =
    void Function(
      double? maxWidth,
      double? maxHeight,
      int? quality,
      int? limit,
      String originText,
      String destinationText,
    );

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FlightTicketPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class FlightTicketPage extends StatefulWidget {
  const FlightTicketPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<FlightTicketPage> createState() => _FlightTicketPageState();
}
class _FlightTicketPageState extends State<FlightTicketPage> {
  List<FlightTicket> tickets = [
    FlightTicket(
      originText: 'Germany (FRA)',
      destinationText: 'France (ORY)',
      path: 'assets/20240425_185330.jpg',
    ),
  ];
  String? _retrieveDataError;

  final TextEditingController originTextController = TextEditingController();
  final TextEditingController destinationTextController =
      TextEditingController();

  Future<void> _onImageButtonPressed(
     {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      await _displayPickImageDialog(context, (
        double? maxWidth,
        double? maxHeight,
        int? quality,
        int? limit,
        String originText,
        String destinationText,
      ) async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          if (result != null) {
            setState(() {
              tickets.add(
                FlightTicket(
                  originText: originText,
                  destinationText: destinationText,
                  path: result.files.single.path!,
                ),
              );
            });
          }
        
      });
    }
  }

  bool isOriginTextEmpty = false;
  bool isDestinationTextEmpty = false;
  Future<void> _displayPickImageDialog(
    BuildContext context,
    OnPickImageCallback onPick,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Information about your ticket'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: originTextController,
                    decoration: InputDecoration(
                      hintText: 'Origin e.g. "Germany (FRA)"',
                      errorText: isOriginTextEmpty
                          ? "Value Can't Be Empty"
                          : null,
                    ),
                  ),
                  TextField(
                    controller: destinationTextController,
                    decoration: InputDecoration(
                      hintText: 'Destination e.g. "France (ORY)"',
                      errorText: isDestinationTextEmpty
                          ? "Value Can't Be Empty"
                          : null,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    setState(() {
                      isOriginTextEmpty = originTextController.text.isEmpty;
                      isDestinationTextEmpty =
                          destinationTextController.text.isEmpty;
                    });
                    if (isOriginTextEmpty || isDestinationTextEmpty) {
                      return;
                    }
                    onPick(
                      250,
                      250,
                      null,
                      1,
                      originTextController.text,
                      destinationTextController.text,
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  

 
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                for (var ticket in tickets)
                  Column(
                    children: [
                      if(_retrieveDataError != null) Text(_retrieveDataError!)
                      else 
                      Flexible(flex: 2, child: _CardWidget(ticket, () => setState(() {
                        ticket.displayFront = false;
                      }))),
                      Flexible(
                        flex: 1,
                        child: Text(
                          "${ticket.originText} - ${ticket.destinationText}",
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_example_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }
}

Widget __transitionBuilder(
  Widget widget,
  Animation<double> animation,
  bool showFrontSide,
) {
  final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
  return AnimatedBuilder(
    animation: rotateAnim,
    child: widget,
    builder: (context, widget) {
      final isUnder = (ValueKey(showFrontSide) != widget!.key);
      var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
      tilt *= isUnder ? -1.0 : 1.0;
      final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
      return Transform(
        transform: (Matrix4.rotationY(value)..setEntry(3, 0, tilt)),
        alignment: Alignment.center,
        child: widget,
      );
    },
  );
}

class _CardWidget extends StatelessWidget {
  final FlightTicket ticket;
  final Function toggleTicketDisplay;

  const _CardWidget(this.ticket,  this.toggleTicketDisplay);

@override 
    Widget build(BuildContext context) {

  
    String? ticketFileMimeStr = lookupMimeType(ticket.path);
    print("ticket file mime type: ${ticketFileMimeStr}");
    Widget fileWidget = Center(
      child: Text('No preview available. Should open file via external tool'),
    );
    if (ticketFileMimeStr != null) {
      if (ticketFileMimeStr.startsWith('image')) {
        fileWidget = FittedBox(
          fit: BoxFit.fill,
          child: InkWell(
          onTap: () {
            var nav = Navigator.of(context);
            nav.push<void>(_createRouteFocusedImage(context, ticket.path));
          },
          child: Image.asset(ticket.path, fit: BoxFit.cover),
        ),
        );
      } else if (ticketFileMimeStr.endsWith('pdf')) {
        fileWidget = InkWell(
          onTap: () => OpenFile.open(ticket.path, type: 'application/pdf'),
          child: Center(child: Icon(Icons.picture_as_pdf)),
        );
        
      }
    }
    
    return GestureDetector(
      onTap: () => toggleTicketDisplay(),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: (widget, animation) =>
            __transitionBuilder(widget, animation, ticket.displayFront),
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
        child: Card(
          key: ValueKey(ticket.displayFront),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: ticket.displayFront ? Colors.blue : Colors.green[100],
          child: ticket.displayFront
              ? Center(child: Text('Front of Ticket'))
              : fileWidget,
        ),
      ),
    );
    }
}




//TODO focus image with
Route _createRouteFocusedImage(BuildContext parentContext, String path) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) {
      return _FocusedImageWidget(path);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rectAnimation = _createTween(
        parentContext,
      ).chain(CurveTween(curve: Curves.ease)).animate(animation);

      return Stack(
        children: [PositionedTransition(rect: rectAnimation, child: child)],
      );
    },
  );
}
Tween<RelativeRect> _createTween(BuildContext context) {
  var windowSize = MediaQuery.of(context).size;
  var box = context.findRenderObject() as RenderBox;
  var rect = box.localToGlobal(Offset.zero) & box.size;
  var relativeRect = RelativeRect.fromSize(rect, windowSize);

  return RelativeRectTween(begin: relativeRect, end: RelativeRect.fill);
}
class _FocusedImageWidget extends StatelessWidget {
  final String path;

  const _FocusedImageWidget(this.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Material(
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(path)//Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

  