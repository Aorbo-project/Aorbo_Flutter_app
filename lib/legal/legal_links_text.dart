import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'legal_documents.dart';
import 'legal_service.dart';

/// "Terms & Conditions | Privacy Policy" (separator configurable) — each
/// half its own tappable link to the server's page. Used under the sign-in
/// form.
class LegalLinksText extends StatefulWidget {
  const LegalLinksText({
    super.key,
    required this.linkStyle,
    required this.separatorStyle,
    this.separator = ' | ',
    this.textAlign = TextAlign.center,
  });

  final TextStyle linkStyle;
  final TextStyle separatorStyle;
  final String separator;
  final TextAlign textAlign;

  @override
  State<LegalLinksText> createState() => _LegalLinksTextState();
}

class _LegalLinksTextState extends State<LegalLinksText> {
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => openLegalDoc(LegalDocKeys.terms);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => openLegalDoc(LegalDocKeys.privacy);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Terms & Conditions', style: widget.linkStyle, recognizer: _termsTap),
          TextSpan(text: widget.separator, style: widget.separatorStyle),
          TextSpan(text: 'Privacy Policy', style: widget.linkStyle, recognizer: _privacyTap),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
