// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => MaterialApp(home: RootScreen());
// }

// class TutorialStep {
//   final Rect rect;
//   final String message;
//   final VoidCallback? onTap;
//   final VoidCallback? onUndo;
//   String next = 'Next';
//   String previous = 'Previous';
//   String skip = 'Skip';

//   TutorialStep({
//     required this.rect,
//     required this.message,
//     this.onTap,
//     this.onUndo,
//     this.next = 'Next',
//     this.previous = 'Previous',
//     this.skip = 'Skip',
//   });
// }

// class RootScreen extends StatefulWidget {
//   @override
//   State<RootScreen> createState() => _RootScreenState();
// }

// class _RootScreenState extends State<RootScreen> {
//   int currentIndex = 0;
//   bool showTutorial = true;
//   int tutorialStep = 0;
//   Color homeBgColor = Colors.white;
//   List<TutorialStep> steps = [];

//   void _gotoPage(int index) => setState(() => currentIndex = index);
//   void _changeHomeColor() => setState(() => homeBgColor = Colors.amber);

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _buildTutorialSteps());
//   }

//   void _buildTutorialSteps() {
//     final screen = MediaQuery.of(context).size;
//     final paddingTop = MediaQuery.of(context).padding.top;
//     final bottomNavHeight = 90.0;
//     final appBarHeight = kToolbarHeight + paddingTop;

//     setState(() {
//       steps = [
//         TutorialStep(
//           rect: Rect.fromLTWH(
//             0,
//             screen.height - bottomNavHeight,
//             screen.width / 3,
//             bottomNavHeight,
//           ),
//           message: "Tab Home",
//           onTap: () => _gotoPage(0),
//         ),
//         TutorialStep(
//           rect: Rect.zero,
//           message:
//               "Selamat datang di aplikasi kami!\nIkuti tur singkat ini untuk mengenal fitur-fitur utama.",
//           onTap: null,
//           next: "Mulai",
//           skip: "Lewati",
//         ),
//         TutorialStep(
//           rect: Rect.fromLTWH(20, appBarHeight + 100, screen.width - 40, 50),
//           message: "Tekan tombol ini untuk mengganti warna latar Home",
//           onTap: _changeHomeColor,
//           onUndo: () => setState(() => homeBgColor = Colors.white),
//         ),
//         TutorialStep(
//           rect: Rect.fromLTWH(
//             screen.width / 3,
//             screen.height - bottomNavHeight,
//             screen.width / 3,
//             bottomNavHeight,
//           ),
//           message: "Tab Search",
//           onTap: () => _gotoPage(1),
//           onUndo:
//               () => {setState(() => homeBgColor = Colors.amber), _gotoPage(0)},
//         ),
//         TutorialStep(
//           rect: Rect.fromLTWH(
//             screen.width / 3 + 40,
//             appBarHeight + 80,
//             screen.width / 3 - 80,
//             50,
//           ),
//           message: "Tekan untuk ke halaman Detail",
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => DetailPage(
//                         onBack: () {
//                           Navigator.pop(context);
//                           _gotoPage(1);
//                         },
//                         showTutorial: showTutorial,
//                         tutorialStep: tutorialStep,
//                         onNextStep: _nextTutorialStep,
//                       ),
//                 ),
//               ),
//           onUndo: () => _gotoPage(0),
//         ),
//         TutorialStep(rect: Rect.fromLTWH(0, 0, 0, 0), message: ""),
//         TutorialStep(
//           rect: Rect.fromLTWH(
//             2 * screen.width / 3,
//             screen.height - bottomNavHeight,
//             screen.width / 3,
//             bottomNavHeight,
//           ),
//           message: "Tab Settings",
//           onTap: () => _gotoPage(2),
//           onUndo: () => {_previousTutorialStep, _gotoPage(1)},
//           next: "Selesai",
//         ),
//       ];
//     });
//   }

//   void _previousTutorialStep() {
//     if (tutorialStep > 0) {
//       final currentStep = steps[tutorialStep];
//       currentStep.onUndo?.call();
//       setState(() => tutorialStep--);
//     }
//   }

//   void _skipTutorial() {
//     setState(() => showTutorial = false);
//   }

//   void _nextTutorialStep() {
//     if (tutorialStep < steps.length - 1) {
//       setState(() => tutorialStep++);
//     } else {
//       setState(() => showTutorial = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: IndexedStack(
//                   index: currentIndex,
//                   children: [
//                     Container(
//                       color: homeBgColor,
//                       child: HomePage(onChangeColor: _changeHomeColor),
//                     ),
//                     SearchPage(
//                       onDetail: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => DetailPage(
//                                   onBack: () {
//                                     Navigator.pop(context);
//                                     _gotoPage(1);
//                                   },
//                                   showTutorial: showTutorial,
//                                   tutorialStep: tutorialStep,
//                                   onNextStep: _nextTutorialStep,
//                                 ),
//                           ),
//                         );
//                       },
//                     ),
//                     SettingsPage(
//                       onRestartTutorial: () {
//                         setState(() {
//                           tutorialStep = 0;
//                           showTutorial = true;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               BottomNavigationBar(
//                 currentIndex: currentIndex,
//                 onTap: (index) => _gotoPage(index),
//                 items: const [
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.home),
//                     label: "Home",
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.search),
//                     label: "Search",
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.settings),
//                     label: "Settings",
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           if (showTutorial && steps.length > tutorialStep) ...[
//             IgnorePointer(
//               ignoring: true,
//               child: CustomPaint(
//                 painter: HolePainter(steps[tutorialStep].rect),
//                 child: Container(),
//               ),
//             ),
//             Positioned.fill(
//               child: GestureDetector(
//                 onTapDown: (details) {
//                   if (steps[tutorialStep].rect.contains(
//                     details.globalPosition,
//                   )) {
//                     steps[tutorialStep].onTap?.call();
//                     if (tutorialStep != 4) _nextTutorialStep();
//                   }
//                 },
//                 child: Container(color: Colors.transparent),
//               ),
//             ),
//             _buildTutorialMessage(steps[tutorialStep]),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildTutorialMessage(TutorialStep step) {
//     final isCenter = step.rect == Rect.zero;
//     final isTop = step.rect.top > MediaQuery.of(context).size.height / 2;

//     return Positioned(
//       left: 20,
//       right: 20,
//       top:
//           isCenter
//               ? MediaQuery.of(context).size.height / 2 - 100
//               : isTop
//               ? step.rect.top - 70
//               : step.rect.bottom + 10,
//       child: Material(
//         color: Colors.transparent,
//         child: Column(
//           children: [
//             Text(
//               step.message,
//               style: TextStyle(color: Colors.white, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: _skipTutorial,
//                   child: Text(step.skip),
//                 ),
//                 if (tutorialStep > 0)
//                   ElevatedButton(
//                     onPressed: _previousTutorialStep,
//                     child: Text(step.previous),
//                   ),
//                 ElevatedButton(
//                   onPressed: _nextTutorialStep,
//                   child: Text(step.next),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DetailPage extends StatelessWidget {
//   final bool showTutorial;
//   final int tutorialStep;
//   final VoidCallback onBack;
//   final VoidCallback onNextStep;

//   const DetailPage({
//     super.key,
//     required this.onBack,
//     required this.showTutorial,
//     required this.tutorialStep,
//     required this.onNextStep,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screen = MediaQuery.of(context).size;
//     final paddingTop = MediaQuery.of(context).padding.top;
//     final appBarHeight = kToolbarHeight + paddingTop;

//     final Rect backButtonRect = Rect.fromLTWH(
//       screen.width / 2 - 50,
//       appBarHeight + 200,
//       100,
//       50,
//     );

//     return Scaffold(
//       body: Stack(
//         children: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 onBack();
//                 if (tutorialStep != 4) {
//                   onNextStep();
//                 }
//               },
//               child: Text("Kembali"),
//             ),
//           ),
//           if (showTutorial && tutorialStep == 4) ...[
//             IgnorePointer(
//               ignoring: true,
//               child: CustomPaint(
//                 painter: HolePainter(backButtonRect),
//                 child: Container(),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 onBack();
//                 onNextStep();
//               },
//               child: Container(color: Colors.transparent),
//             ),
//             Positioned(
//               left: 20,
//               right: 20,
//               top: backButtonRect.bottom + 10,
//               child: Material(
//                 color: Colors.transparent,
//                 child: Text(
//                   "Tekan tombol kembali",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class HolePainter extends CustomPainter {
//   final Rect holeRect;
//   HolePainter(this.holeRect);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.black54;
//     canvas.saveLayer(Offset.zero & size, Paint());
//     canvas.drawRect(Offset.zero & size, paint);
//     paint.blendMode = BlendMode.clear;
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(holeRect, Radius.circular(12)),
//       paint,
//     );
//     canvas.restore();
//   }

//   @override
//   bool shouldRepaint(covariant HolePainter oldDelegate) =>
//       oldDelegate.holeRect != holeRect;
// }

// class HomePage extends StatelessWidget {
//   final VoidCallback onChangeColor;

//   const HomePage({required this.onChangeColor, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: onChangeColor,
//         child: Text("Ganti Warna Latar"),
//       ),
//     );
//   }
// }

// class SearchPage extends StatelessWidget {
//   final VoidCallback onDetail;

//   const SearchPage({required this.onDetail, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(onPressed: onDetail, child: Text("Ke Detail")),
//     );
//   }
// }

// class SettingsPage extends StatelessWidget {
//   final VoidCallback onRestartTutorial;

//   const SettingsPage({required this.onRestartTutorial, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: onRestartTutorial,
//         child: Text("Ulangi Tutorial"),
//       ),
//     );
//   }
// }

// lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/pages/home_page.dart';
import 'package:test123/services/auth_gate.dart';
import 'package:test123/services/classroom_service.dart';
import 'package:test123/services/student_class_service.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://gwwthlylotgwepuuyknh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3d3RobHlsb3Rnd2VwdXV5a25oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTUzNTgsImV4cCI6MjA2NDI3MTM1OH0.lzRAwas43s_dk7FTzTjIrEwzYfk5G5PxEeN7XIvWKFg',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.path == '/join') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          final classroom = await ClassroomService().getClassroomByCode(code);
          final studentId = Supabase.instance.client.auth.currentUser?.id;
          if (classroom != null && studentId != null) {
            final alreadyJoined = await StudentClassService().isStudentInClass(
              classroomId: classroom.id,
              studentId: studentId,
            );
            if (!alreadyJoined) {
              await StudentClassService().joinClass(
                classroomId: classroom.id,
                studentId: studentId,
              );
              // Tampilkan dialog/halaman sukses
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => HomePage(id: studentId, role: 'student'),
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'READAILY',
      home: AuthGate(), // halaman login awal
    );
  }
}

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   String? _selectedFileName;

//   final List<Widget> _pages = [
//     Center(child: Text('Home')),
//     Center(child: Text('Search')),
//     Center(child: Text('Notifications')),
//     Center(child: Text('Profile')),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   void _onFabPressed() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => UploadPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       floatingActionButton: FloatingActionButton(
//         onPressed: _onFabPressed,
//         child: Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifikasi',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
//         ],
//       ),
//     );
//   }
// }

// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/material.dart';

// class UploadPage extends StatefulWidget {
//   @override
//   _UploadPageState createState() => _UploadPageState();
// }

// class _UploadPageState extends State<UploadPage> {
//   String? _fileName;

//   void _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'jpg', 'png'],
//     );

//     if (result != null) {
//       setState(() {
//         _fileName = result.files.single.name;
//       });
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Tidak ada file yang dipilih')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Upload File')),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _pickFile,
//               icon: Icon(Icons.upload_file),
//               label: Text('Pilih File'),
//             ),
//             SizedBox(height: 20),
//             if (_fileName != null)
//               Text('File terpilih: $_fileName', style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'dart:typed_data';

// class UploadedFile {
//   final String id;
//   final String name;
//   final String ownerId;
//   final Uint8List data; // BLOB binary file data
//   final DateTime createdAt;

//   UploadedFile({
//     required this.id,
//     required this.name,
//     required this.ownerId,
//     required this.data,
//     required this.createdAt,
//   });

//   // BLOB biasanya tidak diserialisasi sebagai JSON langsung
//   // Tapi jika pakai base64 encoding:
//   factory UploadedFile.fromJson(Map<String, dynamic> json) {
//     return UploadedFile(
//       id: json['id'],
//       name: json['name'],
//       ownerId: json['ownerId'],
//       data: Uint8List.fromList(List<int>.from(json['data'])),
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'ownerId': ownerId,
//       'data': data.toList(), // kirim sebagai list of int
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }
