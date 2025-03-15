import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConnectionWidget extends StatefulWidget {
  final bool dismissOfflineBanner;
  final Widget Function(BuildContext, bool) builder;

  const ConnectionWidget({
    super.key,
    required this.dismissOfflineBanner,
    required this.builder,
  });

  @override
  State<ConnectionWidget> createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> {
  bool _isOnline = true;
  bool _showBanner = false;
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    setState(() {
      _isOnline = result != ConnectivityResult.none;

      // Only show the banner if we're transitioning from online to offline
      if (wasOnline && !_isOnline) {
        _showBanner = true;
      }

      // If we're back online, hide the banner
      if (_isOnline) {
        _showBanner = false;
      }
    });
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4.r),
                          bottomRight: Radius.circular(4.r),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.red[100]!),
                          right: BorderSide(color: Colors.red[100]!),
                          bottom: BorderSide(color: Colors.red[100]!),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.wifi_off,
                                size: 16.r,
                                color: Colors.red,
                              ),
                              onPressed: null,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No internet connection',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.dismissOfflineBanner)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showBanner = false;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 16.r,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder(context, _isOnline),
        if (_showBanner && !widget.dismissOfflineBanner)
          _buildOfflineBanner(),
      ],
    );
  }
}