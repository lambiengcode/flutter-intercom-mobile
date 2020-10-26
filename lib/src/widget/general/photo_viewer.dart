import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  final String image;

  PhotoViewer({this.image});

  @override
  State<StatefulWidget> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 1.8,
      initialScale: PhotoViewComputedScale.contained,
      basePosition: Alignment.center,
      imageProvider: NetworkImage(widget.image),
    ));
  }
}
