import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppImageData {
  static const _base = 'assets/images';
  static const String logo = '$_base/logo.png';
}

class AppImages extends StatefulWidget {
  final String? path;
  final String? file;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isLoaded;
  const AppImages({
    this.path,
    this.height,
    this.width,
    this.fit,
    this.bytes,
    this.file,
    this.isLoaded = true,
    super.key,
  }) : assert(path != null || bytes != null || file != null);

  @override
  State<AppImages> createState() => _AppImagesState();
}

class _AppImagesState extends State<AppImages> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoaded) {
      return const SizedBox.shrink();
    }
    try {
      if (widget.bytes != null) {
        return Image.memory(
          widget.bytes!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        );
      }
      if (widget.file != null) {
        return Image.file(
          File(widget.file!),
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        );
      }
      return Image.asset(
        widget.path!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    } catch (e) {
      log('Error loading image: $e');
      return const SizedBox.shrink();
    }
  }
} 