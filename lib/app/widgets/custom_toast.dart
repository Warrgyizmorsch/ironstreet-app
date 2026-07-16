// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToast {
  static OverlayEntry? _persistentEntry;

  static void show(
    String message, {
    bool isSuccess = false,
    bool isError = false,
    bool isPersistent = false,
  }) {
    if (isPersistent) {
      dismissPersistent();
    }

    final overlayState = Get.key.currentState?.overlay;

    if (overlayState == null) {
      Get.rawSnackbar(
        message: message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError
            ? const Color(0xFFB71C1C)
            : (isSuccess ? const Color(0xFF1B5E20) : const Color(0xFF1E1E1E)),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        isSuccess: isSuccess,
        isError: isError,
        isPersistent: isPersistent,
        onDismiss: () {
          overlayEntry.remove();
          if (isPersistent && _persistentEntry == overlayEntry) {
            _persistentEntry = null;
          }
        },
      ),
    );

    if (isPersistent) {
      _persistentEntry = overlayEntry;
    }

    overlayState.insert(overlayEntry);
  }

  static void dismissPersistent() {
    if (_persistentEntry != null) {
      _persistentEntry!.remove();
      _persistentEntry = null;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final bool isError;
  final bool isPersistent;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.isSuccess,
    required this.isError,
    required this.isPersistent,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto dismiss after 2.5 seconds (only if NOT persistent)
    if (!widget.isPersistent) {
      Future.delayed(const Duration(milliseconds: 2500), () async {
        if (mounted) {
          await _controller.reverse();
          widget.onDismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFF1E1E1E);
    if (widget.isError) {
      bgColor = const Color(0xFFB71C1C);
    } else if (widget.isSuccess) {
      bgColor = const Color(0xFF1B5E20);
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Company logo container
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.asset(
                              'assets/logo/ironstreetlogo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Color(0xFF222222),
                                  size: 16,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
