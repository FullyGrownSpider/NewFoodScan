import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);


    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _timerTick();
    });

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);
                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text('👀What am I looking at here?'),
              ),
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        color: const Color.fromARGB(255, 90, 90, 90),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              const Text('Scanning!', style: TextStyle(
                                  color: Colors.green, fontSize: 18)),
                              const Text('I\'m doing the best I can!\n\n\n\n\n\n\n', style: TextStyle(
                                  color: Colors.green, fontSize: 7)),
                              const Text('I SEE',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 15)),
                              Text(currentList.replaceAll('\n', ' - '),
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 15)),
                              const Text('\n\n\n\nI SAW',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                              Text(sawList.replaceAll('\n', ' - '),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ],
                          ),
                        ),
                      ))
                ],
              )
                  : Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: const Text(
                    'Camera permission denied',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;
    if (!mounted) return;

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      textUpdate(recognizedText.text);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('I\'m trying but its hard')
        ),
      );
    }
  }

  final List<String> _toLookForMSG = [
    "ve-tsin",
    "vetsin",
    "mononatriumglutamaat",
    "natriumglumaat",
    "monoatrium",
    "glutamaat",
    "monohydraat",
    "glutamic acid",
    "monosodium",
    "gistextract",
    "toegevoegde gist",
    "sodium salt",
  ];
  final List<String> _toLookForGLUT = [
    "tarwe",
    "rogge",
    "gerst",
    "gort",
    "spelt",
    "haver"
  ];

  //https://www.koemelkallergie.nl/Neocate-bij-koemelkallergie/Starten-met-bijvoeding/Met-welke-producten-moet-ik-oppassen
  final List<String> _toLookForMALK = [
    "karnemelk",
    "wei",
    "melkbestanddelen",
    "melkderivaat",
    "wrongel",
    "biogarde",
    "yoghurt",
    "vla",
    "kwark",
    "kefir",
    "umer",
    "caseïne",
    "caseïnaat",
    "melkeiwit",
    "boter",
    "slagroom",
    "melkvet",
    "boterolie",
    "boterconcentraat",
    "melkzout",
    "melkvet",
    "lactose",
    "melksuiker",
    "lactalbumine",
    "β-lactoglobuline",
    "lactoperoxidase",
    "lactoval",
    "recaldent",
    "transglutaminase",
    "nisine",
    "E234",
    "Melk",
    "kaas",
  ];

  String currentList = '';
  String sawList = '';

  void textUpdate(String newText) {
    //check text for things you should check for in the text
    var calc =
        '${_findStuff(_toLookForGLUT, newText)}\n${_findStuff(_toLookForMALK, newText)}\n${_findStuff(_toLookForMSG, newText)}';
    calc = calc.trim().replaceAll('\n\n', '\n');
    var calcList = calc.split('\n');
    var valcList = currentList.split('\n');
    //second check if you didn't see things you did see and put them down
    if (calc != currentList) {
      for (String word in valcList) {
        if (!calc.contains(word)) {
          if (sawList.isNotEmpty) sawList += '\n';
          sawList += word;
        }
      }
    }
    currentList = calc;
    //make sure there are no doubles
    for (String word in calcList) {
      if (sawList.contains(word)) {
        sawList = sawList.replaceFirst(word, '');
      }
    }
    sawList = sawList.trim().replaceAll('\n\n', '\n');
  }

  String _findStuff(List<String> list, String text) {
    for (String word in list) {
      if (text.contains(word)) {
        return word;
      }
    }
    return '';
  }

  void _timerTick() {
    _scanImage();
  }
}
