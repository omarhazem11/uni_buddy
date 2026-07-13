import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

// TODO: swap for the confirmed GitHub Pages URLs once live.
const _termsUrl = 'https://omarhazem11.github.io/uni_verse/terms-of-service.html';
const _privacyUrl = 'https://omarhazem11.github.io/uni_verse/privacy-policy.html';

// Same light-violet accent the header uses for "Uni" — legible on the dark
// AppColors.ink background where AppColors.violet itself reads too dark.
const _linkColor = Color(0xFFA08FFF);

/// "By continuing, you agree to our Terms & Privacy Policy" — "Terms" and
/// "Privacy Policy" are separately tappable links. A StatefulWidget (not the
/// stateless login page) so the TapGestureRecognizers it owns get disposed
/// properly instead of leaking.
class LegalLinksText extends StatefulWidget {
  const LegalLinksText({super.key});

  @override
  State<LegalLinksText> createState() => _LegalLinksTextState();
}

class _LegalLinksTextState extends State<LegalLinksText> {
  late final _termsRecognizer = TapGestureRecognizer()..onTap = () => _open(_termsUrl);
  late final _privacyRecognizer = TapGestureRecognizer()..onTap = () => _open(_privacyUrl);

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.inter(fontSize: 11, color: AppColors.muted, height: 1.5);
    final linkStyle = baseStyle.copyWith(
      color: _linkColor,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: _linkColor,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(text: 'Terms', style: linkStyle, recognizer: _termsRecognizer),
          const TextSpan(text: ' & '),
          TextSpan(text: 'Privacy Policy', style: linkStyle, recognizer: _privacyRecognizer),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
