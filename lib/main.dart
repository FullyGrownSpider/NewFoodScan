import 'package:flutter/material.dart';

import 'Screens/scan_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const PickingScreen(),
    );
  }
}

class PickingScreen extends StatefulWidget {
  const PickingScreen({Key? key}) : super(key: key);

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  // TextEditingController stringController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Center(
              child:
                blagendaUniformButton(Colors.blue, 'Scan Ingredients', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScanScreen()));
                }),
        ));
  }
}

Widget blagendaUniformButton(Color c, String s, void Function() pressed) =>
    ElevatedButton(
        onPressed: pressed,
        style: ElevatedButton.styleFrom(backgroundColor: c),
        child: s.contains('\n')
            ? Column(children: [
                Text(s.substring(0, s.indexOf('\n')),
                    style: normalTextStyleBold, textAlign: TextAlign.center),
                smallBlankSplit,
                smallBlankSplit,
                Text(s.substring(s.indexOf('\n') + 1),
                    style: normalTextStyle, textAlign: TextAlign.center),
                const Text(
                  '-\n\n-',
                  style: smallStyle,
                )
              ])
            : Text(s, style: normalTextStyle, textAlign: TextAlign.center));
const TextStyle bigTextStyle = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle secondaryBigTextStyle = TextStyle(
    fontSize: 18.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent);
const TextStyle bigTextStyleYesterday = TextStyle(
    fontSize: 22.0,
    height: 1.7,
    fontWeight: FontWeight.bold,
    color: Colors.white30);
const TextStyle normalTextStyle = TextStyle(
    fontSize: 14.0,
    height: 1.4,
    fontWeight: FontWeight.bold,
    color: Colors.black);
const TextStyle normalTextStyleBold = TextStyle(
    fontSize: 14.0,
    height: 1.4,
    fontWeight: FontWeight.w900,
    color: Colors.black);

const Text splitterTextField = Text('              ',
    style: TextStyle(fontSize: 8.0, color: Colors.green));
const Text bigSplitterTextField = Text('≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡',
    style: TextStyle(fontSize: 20.0, height: 2.5, color: Colors.green));

const TextStyle smallStyle = TextStyle(fontSize: 4.0, color: Colors.green);
const Text smallBlankSplit = Text('            ', style: smallStyle);
const Text smallerBlankSplit =
    Text(' ', style: TextStyle(fontSize: 2.0, color: Colors.green));
