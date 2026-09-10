import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebView extends StatefulWidget {
  final String title;
  final String url;

  const LegalWebView({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<LegalWebView> createState() => _LegalWebViewState();
}

class _LegalWebViewState extends State<LegalWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final isDark = Get.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) async {
            final isDarkCurrent = Theme.of(context).brightness == Brightness.dark;
            await _injectCustomStyleAndClean(isDarkCurrent);

            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _injectCustomStyleAndClean(bool isDark) async {
    final bgColor = isDark ? '#121212' : '#ffffff';
    final textColor = isDark ? '#e0e0e0' : '#222222';
    final headingColor = isDark ? '#ffffff' : '#111111';

    await _controller.runJavaScript('''
      (function() {
        // 1. Remove website header, footer, popups, and floating buttons
        document.querySelectorAll(
          '.header-container, .footer, .title-breadcrumb, #simple-chat-button--container, .pum-overlay, #back-top, header, footer, .site-header, .site-footer'
        ).forEach(el => el.remove());

        // 2. Inject clean style sheet to prevent font blur and layout breakage
        let style = document.getElementById('ironstreet-custom-style');
        if (!style) {
          style = document.createElement('style');
          style.id = 'ironstreet-custom-style';
          document.head.appendChild(style);
        }

        style.innerHTML = `
          html, body {
            background-color: $bgColor !important;
            color: $textColor !important;
            margin: 0 !important;
            padding: 0 !important;
            -webkit-font-smoothing: antialiased !important;
            -moz-osx-font-smoothing: grayscale !important;
            text-rendering: optimizeLegibility !important;
          }
          .main-container, .main-container .container, .main-container .row, #content, .site-content, .entry-content, article {
            background-color: $bgColor !important;
            color: $textColor !important;
            margin-top: 0 !important;
            padding-top: 0 !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
          }
          .main-container .container {
            padding: 16px !important;
          }
          h1, h2, h3, h4, h5, h6 {
            color: $headingColor !important;
            font-weight: 700 !important;
            line-height: 1.3 !important;
          }
          h1 { font-size: 22px !important; margin-bottom: 16px !important; }
          h2 { font-size: 18px !important; margin-top: 20px !important; margin-bottom: 10px !important; }
          h3 { font-size: 16px !important; margin-top: 16px !important; margin-bottom: 8px !important; }
          p, li, td, th {
            color: $textColor !important;
            font-size: 14px !important;
            line-height: 1.7 !important;
          }
          a {
            color: #F03B3B !important;
          }
          .header-container, .footer, .title-breadcrumb, #simple-chat-button--container, .pum-overlay, #back-top {
            display: none !important;
          }
        `;
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color ??
                Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.title.isNotEmpty ? widget.title : 'Iron Street',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF37021)),
              ),
            ),
        ],
      ),
    );
  }
}
