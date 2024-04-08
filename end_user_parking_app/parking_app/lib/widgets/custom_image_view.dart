import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomImageView extends StatelessWidget {
  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final String placeholder;

  CustomImageView({
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeholder = 'assets/car.png',
  });

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: buildWidget(),
          )
        : buildWidget();
  }

  Widget buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: buildCircleImage(),
      ),
    );
  }

  Widget buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: buildImageWithBorder(),
      );
    } else {
      return buildImageWithBorder();
    }
  }

  Widget buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: buildImageView(),
      );
    } else {
      return buildImageView();
    }
  }

  Widget buildImageView() {
  if (imagePath != null) {
    switch (imagePath!.imageType) {
      case ImageType.svg:
        return Container(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            color: color, // Use the color parameter directly
          ),
        );
      case ImageType.file:
        return Image.file(
          File(imagePath!),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: imagePath!,
          color: color,
          placeholder: (context, url) => Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: Colors.grey.shade200,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeholder,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          ),
        );
      case ImageType.png:
      default:
        return Image.asset(
          imagePath!,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }
  return SizedBox();
}

}

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (this.startsWith('http') || this.startsWith('https')) {
      return ImageType.network;
    } else if (this.endsWith('.svg')) {
      return ImageType.svg;
    } else if (this.startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }