// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';

// class LegalWebView extends StatefulWidget {
//   final String title;
//   final String url;

//   const LegalWebView({
//     super.key,
//     required this.title,
//     required this.url,
//   });

//   @override
//   State<LegalWebView> createState() => _LegalWebViewState();
// }

// class _LegalWebViewState extends State<LegalWebView> {
//   late final WebViewController _controller;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               _isLoading = false;
//             });
//             // Inject JavaScript to hide website headers, footers, and topbar elements
//             _controller.runJavaScript('''
//               (function() {
//                 const selectors = [
//                   'header', '.site-header', '.header-wrapper', '.masthead',
//                   'footer', '.site-footer', '.footer-wrapper', '.colophon',
//                   '.top-bar', '.entry-header-wrapper', '.mobile-header',
//                   '.header-mobile', '#header', '#footer', '.page-title-section'
//                 ];
//                 selectors.forEach(selector => {
//                   document.querySelectorAll(selector).forEach(element => {
//                     element.style.display = 'none';
//                   });
//                 });

//                 // Adjust content container padding or margin for clean layout
//                 const contentSelectors = ['#content', '.site-content', '.main-content-wrapper'];
//                 contentSelectors.forEach(sel => {
//                   document.querySelectorAll(sel).forEach(el => {
//                     el.style.paddingTop = '0px';
//                     el.style.marginTop = '0px';
//                   });
//                 });
//               })();
//             ''');
//           },
//           onWebResourceError: (WebResourceError error) {},
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           widget.title,
//           style: GoogleFonts.poppins(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF37021)),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) async {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            await _removeWebsiteHeaderFooter(isDark);

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

  Future<void> _removeWebsiteHeaderFooter(bool isDark) async {
    await _controller.runJavaScript('''
      (function() {
        document.querySelectorAll(
          '.header-container, .footer, .title-breadcrumb, #simple-chat-button--container, .pum-overlay, #back-top'
        ).forEach(el => el.remove());

        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.backgroundColor = '${isDark ? "#121212" : "#ffffff"}';

        const main = document.querySelector('.main-container');
        if (main) {
          main.style.marginTop = '0';
          main.style.paddingTop = '0';
        }

        const container = document.querySelector('.main-container .container');
        if (container) {
          container.style.width = '100%';
          container.style.maxWidth = '100%';
          container.style.padding = '16px';
          container.style.boxSizing = 'border-box';
        }

        const row = document.querySelector('.main-container .row');
        if (row) {
          row.style.margin = '0';
        }

        document.querySelectorAll('h1').forEach(h1 => {
          h1.style.fontSize = '24px';
          h1.style.marginBottom = '20px';
          h1.style.color = '${isDark ? "#ffffff" : "#222222"}';
        });

        document.querySelectorAll('p, li, span, h2, h3, h4, h5, h6, div, td, th').forEach(text => {
          if ($isDark) {
            text.style.color = '#e0e0e0';
          } else {
            text.style.color = '#333333';
          }
          text.style.fontSize = '14px';
          text.style.lineHeight = '1.7';
        });
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
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Theme.of(context).textTheme.titleLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Iron Street',
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
