import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final WidgetBuilder? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedPath = imagePath.trim();

    if (trimmedPath.isEmpty) {
      return _buildError(context, 'Empty image path', null);
    }

    if (trimmedPath.startsWith('assets/')) {
      return Image.asset(
        trimmedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            _buildError(context, error, stackTrace),
      );
    }

    return CachedNetworkImage(
      imageUrl: trimmedPath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null
          ? (context, url) => placeholder!(context)
          : null,
      errorWidget: (context, url, error) =>
          _buildError(context, error, null),
    );
  }

  Widget _buildError(BuildContext context, Object error, StackTrace? stackTrace) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error, stackTrace);
    }
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 24),
      ),
    );
  }
}
