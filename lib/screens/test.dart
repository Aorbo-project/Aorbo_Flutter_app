// import 'package:flutter/material.dart';
//
// class TapEffectTextField extends StatefulWidget {
//   @override
//   _TapEffectTextFieldState createState() => _TapEffectTextFieldState();
// }
//
// class _TapEffectTextFieldState extends State<TapEffectTextField> {
//   final FocusNode _focusNode = FocusNode();
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       body: Center(
//         child: Material(
//           color: Colors.transparent,
//           child: Ink(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Colors.grey.shade400),
//             ),
//             child: InkWell(
//               splashColor: Colors.grey.withValues(alpha: 0.3),
//               highlightColor: Colors.grey.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12.r),
//               onTap: () {
//                 debugPrint("InkWell tapped");
//                 FocusScope.of(context).requestFocus(_focusNode);
//               },
//               child: Container(
//                 width: 320,
//                 height: 60,
//                 alignment: Alignment.centerLeft,
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: TextField(
//                   controller: _controller,
//                   focusNode: _focusNode,
//                   style: TextStyle(fontSize: 13),
//                   decoration: InputDecoration.collapsed(
//                     hintText: 'Tap here for ripple',
//                   ),
//                   onTap: () {
//                     debugPrint("TextField tapped");
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

