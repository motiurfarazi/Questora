import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders a string that contains a mix of Bangla/plain text and
/// inline LaTeX wrapped in `$...$`.
///
/// Example input:
///   `"$sin² (cos^{-1}{1\over 2})$ এর মান—"`
///
/// It splits on `$` boundaries, odd segments are LaTeX, even are plain text.
class MathTextRender extends StatelessWidget {
  final String htmlContent;
  final bool hasMath;
  final TextStyle? textStyle;

  const MathTextRender({
    super.key,
    required this.htmlContent,
    this.hasMath = false,
    this.textStyle,
  });

  /// Inline math ($...$) regex parser.
  static final _inlineMath = RegExp(r'\$([^$]+?)\$');

  /// Returns true when the string contains at least one $...$ token.
  static bool _containsInlineMath(String text) => _inlineMath.hasMatch(text);

  /// Builds a Wrap of [TextSpan]-like widgets by splitting on `$...$`.
  Widget _buildMixedContent(String raw, TextStyle base, BuildContext ctx) {
    final parts = raw.split(_inlineMath);
    final matches = _inlineMath.allMatches(raw).toList();

    final children = <Widget>[];
    int matchIdx = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        // Plain text / HTML segment
        children.add(
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              _stripSimpleHtml(parts[i]),
              style: base,
              textAlign: TextAlign.start,
            ),
          ),
        );
      }
      // After every plain segment there may be a math match
      if (matchIdx < matches.length) {
        final latexRaw = matches[matchIdx].group(1)!.trim();
        final latex = _decodeHtmlEntities(latexRaw);
        children.add(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              latex,
              textStyle: base.copyWith(fontSize: (base.fontSize ?? 16) - 1),
              onErrorFallback: (e) => Text(
                '[\$$latex\$]',
                style: base.copyWith(color: Colors.red[300]),
              ),
            ),
          ),
        );
        matchIdx++;
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: children,
    );
  }

  /// Decodes HTML entities commonly found in scraped equations
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ');
  }

  /// Very lightweight HTML stripper for plain-text segments — removes common
  /// tags like <p>, <br>, <strong> before passing to Text().
  static String _stripSimpleHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: textStyle?.fontSize ?? 16.0,
      fontWeight: textStyle?.fontWeight ?? FontWeight.normal,
      color: textStyle?.color ?? const Color(0xFF1A1A2E),
      height: 1.5,
    );

    final containsMath = hasMath || _containsInlineMath(htmlContent);

    if (containsMath) {
      // If the whole string is a pure LaTeX expression (no HTML tags, starts
      // with $) render it directly for better centering.
      final trimmed = htmlContent.trim();
      if (trimmed.startsWith(r'$') &&
          trimmed.endsWith(r'$') &&
          !trimmed.substring(1, trimmed.length - 1).contains(r'$')) {
        final latexRaw = trimmed.substring(1, trimmed.length - 1).trim();
        final latex = _decodeHtmlEntities(latexRaw);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            latex,
            textStyle: base,
            onErrorFallback: (e) => Text('[\$$latex\$]', style: base),
          ),
        );
      }
      return _buildMixedContent(htmlContent, base, context);
    }

    // Pure HTML, no math — use flutter_html
    return Html(
      data: htmlContent,
      style: {
        'body': Style(
          fontSize: FontSize(base.fontSize!),
          fontWeight: base.fontWeight,
          color: base.color,
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(margin: Margins.zero),
      },
    );
  }
}
