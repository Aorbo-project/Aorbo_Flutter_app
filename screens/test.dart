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
//       backgroundColor: grey500,
//       body: Center(
//         child: Material(
//           color: transparent,
//           child: Ink(
//             decoration: BoxDecoration(
//               color: white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: grey500),
//             ),
//             child: InkWell(
//               splashColor: grey500.withValues(alpha: 0.3),
//               highlightColor: grey500.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12.r),
//               onTap: () {
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
