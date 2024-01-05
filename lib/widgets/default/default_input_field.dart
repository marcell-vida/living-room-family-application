import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/util/constants.dart';

class DefaultInputField extends StatelessWidget {
  final void Function(String)? callback;
  final String? initialValue;
  final String? text;
  final String? hintText;
  final bool? obscureText;
  final String? suffixText;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final IconData? leadIcon;
  final TextInputAction? textInputAction;
  final int maxLength;
  final int minLines;
  final int? maxLines;
  final Color textColor;
  final Color? defaultBorderColor;
  final Color errorBorderColor;
  final Color selectedBorderColor;
  final Function? validator;
  final Function? validatorMessage;
  final Function? obscureIconTap;
  final Function? suffixIconTap;
  final TextInputFormatter? textInputFormatter;
  final TextInputType? textInputType;
  final TextEditingController? textEditingController;

  const DefaultInputField(
      {Key? key,
      required this.callback,
      this.initialValue,
      this.text,
      this.hintText,
      this.obscureText,
      this.suffixText,
      this.suffixIcon,
      this.leadIcon,
      this.textInputAction,
      this.validator,
      this.validatorMessage,
      this.maxLength = 250,
      this.minLines = 1,
      this.maxLines,
      this.obscureIconTap,
      this.suffixIconTap,
      this.textColor = AppColors.white,
      this.defaultBorderColor,
      this.errorBorderColor = AppColors.red,
      this.selectedBorderColor = AppColors.purple,
      this.suffixIconColor,
      this.textInputFormatter,
      this.textInputType,
      this.textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Theme(
      data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: textColor,
              selectionColor: textColor,
              selectionHandleColor: textColor)),
      child: TextFormField(
        controller: textEditingController,
        cursorColor: textColor,
        initialValue: initialValue,
        onChanged: callback,
        onFieldSubmitted: callback,
        validator: (input) {
          if (validator != null && validator!() == false) {
            return validatorMessage != null
                ? validatorMessage!()
                : ''; //widget.validatorMessage!;
          } else {
            return null;
          }
        },
        minLines: minLines,
        maxLines: maxLines ?? minLines,
        keyboardType: textInputType,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
          if (textInputFormatter != null) textInputFormatter!
        ],
        textInputAction: textInputAction,
        obscureText: obscureText == true,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
              borderRadius: Constants.borderRadius,
              borderSide: BorderSide(
                  width: Constants.borderWidth, color: errorBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Constants.borderRadius,
              borderSide: BorderSide(
                  width: Constants.borderWidth, color: selectedBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Constants.borderRadius,
              borderSide: BorderSide(
                  width: Constants.borderWidth,
                  color: defaultBorderColor ?? AppColors.whiteOp30),
            ),
            contentPadding: AppPaddings.inputField,
            border: OutlineInputBorder(borderRadius: Constants.borderRadius),
            labelText: hintText,
            labelStyle: GoogleFonts.inter(
                fontSize: 14.0, fontWeight: FontWeight.w600, color: textColor),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
                fontSize: 14.0, fontWeight: FontWeight.w600, color: textColor),
            suffixText: suffixText,
            errorMaxLines: 3,
            errorStyle: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.red),
            suffixIcon: suffix,
            prefixIcon: leadIcon != null
                ? Icon(leadIcon,
                    color: defaultBorderColor ?? AppColors.whiteOp30)
                : null),
      ),
    ));
  }

  Widget? get suffix {
    IconData? iconData;
    Function? onPressed;
    if (suffixIcon != null) {
      iconData = suffixIcon!;
      onPressed = suffixIconTap;
    } else if (obscureText == true) {
      iconData = Icons.visibility_rounded;
      onPressed = obscureIconTap;
    } else if (obscureText == false) {
      iconData = Icons.visibility_off_rounded;
      onPressed = obscureIconTap;
    }

    if (iconData == null) return null;

    return ExcludeFocus(
        child: IconButton(
            onPressed: () => onPressed?.call(),
            icon: Icon(iconData,
                color: suffixIconColor ??
                    defaultBorderColor ??
                    AppColors.whiteOp30)));
  }
}
