import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iron_street_app/app/modules/cart/cart_controller.dart';
import 'package:iron_street_app/app/modules/payment/payment_success_view.dart';
import 'package:iron_street_app/app/modules/payment/payment_failed_view.dart';
import 'checkout_controller.dart';

class CheckoutWebView extends StatefulWidget {
  final String url;
  final String orderId;
  final String orderNumber;

  const CheckoutWebView({
    super.key,
    required this.url,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFinished = false; // to prevent double navigation

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('Checkout WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkUrl(String url) {
    if (_isFinished) return;

    final lowerUrl = url.toLowerCase();
    
    // Check for success URL (contains 'order-received')
    if (lowerUrl.contains('order-received')) {
      _isFinished = true;
      _handlePaymentSuccess();
    }
    // Check for cancellation/failure URL (often contains 'cancel_order', 'payment-failed', etc.)
    else if (lowerUrl.contains('cancel_order') || lowerUrl.contains('payment-failed') || lowerUrl.contains('payment_failed')) {
      _isFinished = true;
      _handlePaymentFailure();
    }
  }

  void _handlePaymentSuccess() {
    // 1. Clear cart
    final cartCtrl = Get.find<CartController>();
    cartCtrl.clearCart();

    // 2. Clear coupon discount
    final checkCtrl = Get.find<CheckoutController>();
    checkCtrl.removeCoupon();

    // 3. Navigate to success screen, replace current route
    Get.off(() => PaymentSuccessView(
          orderNumber: widget.orderNumber,
          orderId: widget.orderId,
        ));
  }

  void _handlePaymentFailure() {
    // Navigate to failure screen, replace current route
    Get.off(() => const PaymentFailedView());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Show confirmation dialog before exiting
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Cancel Payment?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to cancel the payment process?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'No, Continue',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Yes, Cancel',
                  style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          _isFinished = true;
          _handlePaymentFailure();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () async {
              // Trigger pop flow to show dialog
              Navigator.of(context).maybePop();
            },
          ),
          centerTitle: true,
          title: Text(
            'Secure Payment',
            style: GoogleFonts.poppins(
              color: Colors.black87,
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
      ),
    );
  }
}
