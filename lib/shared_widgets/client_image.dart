
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zk_note/shared/assets.dart';

class ClientSquareImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets? margin;

  const ClientSquareImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    this.borderRadius,
    this.margin
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: borderRadius
      ),

      child: imageUrl != null? ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: width,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(AssetImages.hourglass),
            );
          },
          errorWidget: (context, url, error) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(AssetImages.hourglass),
            );
          },
        ),
      ) : Icon(Icons.person, size: width, color: Colors.white),
    );
  }
}

