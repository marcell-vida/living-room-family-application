import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class DefaultAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final double borderWidth;
  final String? initialsText;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool cacheImage;
  final bool showInitialTextAbovePicture;
  final void Function()? onTap;
  final Widget? child;
  final Widget Function(BuildContext, String)? placeHolder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const DefaultAvatar(
      {Key? key,
      this.url,
      this.radius = 70,
      this.borderWidth = Constants.borderWidth,
      this.initialsText,
      this.foregroundColor = Colors.transparent,
      this.backgroundColor = AppColors.white,
      this.borderColor = AppColors.purple,
      this.showInitialTextAbovePicture = false,
      this.onTap,
      this.child,
      this.placeHolder,
      this.errorWidget,
      this.cacheImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return CircleAvatar(
    //   backgroundImage: NetworkImage(url ?? ''),
    //   radius: radius,
    //   foregroundColor: foregroundColor,
    //   backgroundColor: backgroundColor,
    //   child: child,
    // );
    return CircularProfileAvatar(
      url ?? '',
      placeHolder:
          placeHolder ?? (_, __) => Image.asset('assets/images/app_icon.png'),
      errorWidget: errorWidget ??
          (_, __, ___) => Image.asset('assets/images/app_icon.png'),
      radius: radius,
      animateFromOldImageOnUrlChange: false,
      initialsText: Text(
        initialsText ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      showInitialTextAbovePicture: showInitialTextAbovePicture,
      borderColor: borderColor,
      borderWidth: borderWidth,
      cacheImage: cacheImage,
      onTap: onTap,
      child: child,
    );
  }
}
