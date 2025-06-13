import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/sync_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'dart:async';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  final SyncService _syncService = locator<SyncService>();
  late StreamSubscription<SyncStatus> _syncStatusSubscription;
  late StreamSubscription<String> _syncMessageSubscription;
  late StreamSubscription<double> _syncProgressSubscription;

  bool _isOnline = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  String _syncMessage = '';
  double _syncProgress = 0.0;
  int _pendingOperations = 0;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _setupListeners();
    _loadSyncStats();
  }

  void _initializeConnectivity() async {
    _isOnline = await _syncService.isOnline();
    if (mounted) setState(() {});
  }

  void _setupListeners() {
    _syncStatusSubscription = _syncService.syncStatus.listen((status) {
      if (mounted) {
        setState(() {
          _syncStatus = status;
        });
      }
    });

    _syncMessageSubscription = _syncService.syncMessage.listen((message) {
      if (mounted) {
        setState(() {
          _syncMessage = message;
        });
      }
    });

    _syncProgressSubscription = _syncService.syncProgress.listen((progress) {
      if (mounted) {
        setState(() {
          _syncProgress = progress;
        });
      }
    });

    // Check connectivity every 10 seconds
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _checkConnectivity();
    });
  }

  void _checkConnectivity() async {
    final isOnline = await _syncService.isOnline();
    if (mounted && isOnline != _isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
      if (isOnline) {
        _loadSyncStats();
      }
    }
  }

  void _loadSyncStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      if (mounted) {
        setState(() {
          _pendingOperations = stats['pendingOperations'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading sync stats: $e');
    }
  }

  @override
  void dispose() {
    _syncStatusSubscription.cancel();
    _syncMessageSubscription.cancel();
    _syncProgressSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 90.w,
        maxWidth: 110.w,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(),
              SizedBox(width: 6.w),
              Text(
                _getStatusText(),
                style: AppTextStyle.semibold12.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Progress indicator
          if (_syncStatus == SyncStatus.syncing) ...[
            SizedBox(height: 4.h),
            LinearProgressIndicator(
              value: _syncProgress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 2.h,
            ),
            if (_syncMessage.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                _syncMessage,
                style: AppTextStyle.regular10.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],

          // Pending changes
          if (!_isOnline && _pendingOperations > 0) ...[
            SizedBox(height: 2.h),
            Text(
              '$_pendingOperations pending changes',
              style: AppTextStyle.regular10.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_syncStatus) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16.r,
          height: 16.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case SyncStatus.success:
        return Icon(
          Icons.check_circle,
          size: 16.r,
          color: Colors.white,
        );
      case SyncStatus.error:
        return Icon(
          Icons.error,
          size: 16.r,
          color: Colors.white,
        );
      default:
        return Icon(
          _isOnline ? Icons.cloud_done : Icons.cloud_off,
          size: 16.r,
          color: Colors.white,
        );
    }
  }

  String _getStatusText() {
    if (_syncStatus == SyncStatus.syncing) {
      return 'Syncing...';
    } else if (_syncStatus == SyncStatus.success) {
      return 'Synced';
    } else if (_syncStatus == SyncStatus.error) {
      return 'Sync Error';
    } else if (_isOnline) {
      return 'Online';
    } else {
      return 'Offline Mode';
    }
  }

  Color _getStatusColor() {
    if (_syncStatus == SyncStatus.syncing) {
      return Colors.blue;
    } else if (_syncStatus == SyncStatus.success) {
      return Colors.green;
    } else if (_syncStatus == SyncStatus.error) {
      return Colors.red;
    } else if (_isOnline) {
      return AppColors.primary;
    } else {
      return Colors.orange;
    }
  }
}
