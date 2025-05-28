import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/sync_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'dart:async';

class SyncControlsWidget extends StatefulWidget {
  final VoidCallback? onRefreshRequested;

  const SyncControlsWidget({
    super.key,
    this.onRefreshRequested,
  });

  @override
  State<SyncControlsWidget> createState() => _SyncControlsWidgetState();
}

class _SyncControlsWidgetState extends State<SyncControlsWidget> {
  final SyncService _syncService = locator<SyncService>();
  late StreamSubscription<SyncStatus> _syncStatusSubscription;

  bool _isOnline = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _setupListeners();
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
    }
  }

  @override
  void dispose() {
    _syncStatusSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (!_isOnline || _syncStatus == SyncStatus.syncing) return;

    try {
      final success = await _syncService.sync(showProgress: true);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(success ? 'Sync completed successfully' : 'Sync failed'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    if (!_isOnline || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _syncService.refreshData();
      if (!mounted) return;

      // Notify parent to refresh the map
      widget.onRefreshRequested?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map data refreshed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refresh failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sync Button
        FloatingActionButton(
          heroTag: 'sync',
          mini: true,
          backgroundColor: _isOnline ? AppColors.primary : Colors.grey,
          onPressed: _isOnline && _syncStatus != SyncStatus.syncing
              ? _handleSync
              : null,
          child: _syncStatus == SyncStatus.syncing
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.sync,
                  color: _isOnline ? Colors.white : Colors.grey[400],
                  size: 20.r,
                ),
        ),
        SizedBox(height: 8.h),
        // Refresh Button
        FloatingActionButton(
          heroTag: 'refresh',
          mini: true,
          backgroundColor: _isOnline ? Colors.blue : Colors.grey,
          onPressed: _isOnline && !_isRefreshing ? _handleRefresh : null,
          child: _isRefreshing
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  color: _isOnline ? Colors.white : Colors.grey[400],
                  size: 20.r,
                ),
        ),
      ],
    );
  }
}
