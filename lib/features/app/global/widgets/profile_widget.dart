// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:whatsapp_clone/features/app/theme/styles.dart';

// Widget profileWidget({String? imageUrl, File? image}) {
//   if (image == null) {
//     if (imageUrl == null || imageUrl == "") {
//       return Image.asset(
//         'assets/profile_default.png',
//         fit: BoxFit.cover,
//       );
//     } else {
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         fit: BoxFit.cover,
//         progressIndicatorBuilder: (context, url, downloadProgress) {
//           return const CircularProgressIndicator(
//             color: tabColor,
//           );
//         },
//         errorWidget: (context, url, error) => Image.asset(
//           'assets/profile_default.png',
//           fit: BoxFit.cover,
//         ),
//       );
//     }
//   } else {
//     return Image.file(
//       image,
//       fit: BoxFit.cover,
//     );
//   }
// }

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

Widget profileWidget({
  String? imageUrl,
  File? image,
  double? width,
  double? height,
  bool isCircular = true,
}) {
  Widget imageWidget;

  if (image == null) {
    if (imageUrl == null || imageUrl == "") {
      imageWidget = Image.asset(
        'assets/profile_default.png',
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: tabColor,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          child: Image.asset(
            'assets/profile_default.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  } else {
    imageWidget = Image.file(
      image,
      fit: BoxFit.cover,
      width: width,
      height: height,
    );
  }

  // Ensure the image fills the container properly
  return SizedBox(
    width: width,
    height: height,
    child: imageWidget,
  );
}
