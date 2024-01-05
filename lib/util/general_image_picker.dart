import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_action_chip.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class GeneralImagePicker {
  final BuildContext context;
  final int imageQuality;
  final String? pickSheetTitle;
  final String? approveSheetTitle;
  final String? pickSheetInfo;
  final String? approveSheetInfo;
  final String? currentUrl;
  final String? currentPath;
  final String? pickSheetDescription;
  final String? approveSheetDescription;
  final Function(String?)? onChooseDone;
  final Function(bool?)? onApprovalDone;

  GeneralImagePicker(
      {required this.context,
      this.imageQuality = 20,
      this.pickSheetTitle,
      this.approveSheetTitle,
      this.pickSheetInfo,
      this.approveSheetInfo,
      this.currentUrl,
      this.currentPath,
      this.pickSheetDescription,
      this.approveSheetDescription,
      this.onChooseDone,
      this.onApprovalDone});

  void show() {
    debugPrint('GeneralImagePicker: currentPath is $currentPath');

    onApproved(bool? modify) {
      onApprovalDone?.call(modify);
      if (modify != null) {
        Navigator.of(context).pop();
      }
    }

    onModificationDone(String? imagePath) {
      onChooseDone?.call(imagePath);
      if (imagePath != null) {
        _approvalSheet(newImagePath: imagePath, onApproved: onApproved);
      }
    }

    _pickSheet(onChosen: onModificationDone);
  }

  Future _pickImage(
      {required ImageSource imageSource,
      required Function(String) onDone,
      int? imageQuality}) async {
    final returnedImage = await ImagePicker()
        .pickImage(source: imageSource, imageQuality: imageQuality);

    if (returnedImage == null) return;

    onDone(returnedImage.path);
  }

  void _pickSheet({void Function(String?)? onChosen}) {
    List<Widget> content = [
      if (pickSheetTitle != null) ...[
        DefaultText(
          pickSheetTitle!,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        const VerticalSpacer.of23()
      ],
      if (currentUrl != null) ...[
        Center(
          child: DefaultAvatar(
            url: currentUrl,
            radius: 130,
          ),
        ),
        const VerticalSpacer.of40(),
      ],
      if (currentUrl == null &&
          currentPath != null &&
          currentPath!.isNotEmpty) ...[
        Center(
          child: DefaultAvatar(
            radius: 130,
            child: Image.file(
              File(currentPath ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const VerticalSpacer.of40(),
      ],
      DefaultActionChip(
          title: context.loc?.settingsScreenPictureGallery,
          icon: Icons.image_outlined,
          onTap: () {
            _pickImage(
                imageSource: ImageSource.gallery,
                imageQuality: imageQuality,
                onDone: (String imagePath) {
                  onChosen?.call(imagePath);
                });
          }),
      DefaultActionChip(
          title: context.loc?.settingsScreenPictureCamera,
          icon: Icons.camera_alt_outlined,
          onTap: () {
            _pickImage(
                imageSource: ImageSource.camera,
                imageQuality: imageQuality,
                onDone: (String imagePath) {
                  onChosen?.call(imagePath);
                });
          }),
      DefaultActionChip(
        title: context.loc?.settingsScreenPictureReset,
        icon: Icons.settings_backup_restore_outlined,
        onTap: () {
          onChosen?.call('');
        },
      )
    ];

    context.showBottomSheet(
        children: content,
        onDone: onChosen,
        extraIcon: pickSheetInfo != null ? Icons.help_outline : null,
        onExtraIconTap: () => context.showInfoSheet(pickSheetInfo ?? ''));
  }

  void _approvalSheet(
      {String? newImagePath, void Function(bool?)? onApproved}) {
    List<Widget> content = [
      if (approveSheetTitle != null) ...[
        DefaultText(
          approveSheetTitle!,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        const VerticalSpacer.of40()
      ],
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            children: [
              if (currentUrl != null) ...[
                DefaultAvatar(
                  url: currentUrl,
                  borderColor: AppColors.sand,
                ),
                const HorizontalSpacer.of10(),
              ],
              if (currentUrl == null &&
                  currentPath != null &&
                  currentPath!.isNotEmpty) ...[
                DefaultAvatar(
                  borderColor: AppColors.sand,
                  child: Image.file(
                    File(currentPath ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                const HorizontalSpacer.of10(),
              ],
              DefaultAvatar(
                url: newImagePath == '' ? Constants.logoUrl : '',
                placeHolder: newImagePath == ''
                    ? (_, __) => Image.file(File(newImagePath ?? ''))
                    : (_, __) => const Icon(
                          Icons.person,
                          color: AppColors.purple,
                        ),
                borderColor: AppColors.purple,
                borderWidth: Constants.borderWidth + 2,
                child: Image.file(
                  File(newImagePath ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          if (approveSheetDescription != null) ...[
            const VerticalSpacer.of40(),
            DefaultText(
              approveSheetDescription!,
              textAlign: TextAlign.center,
              color: AppColors.grey2,
            )
          ],
          const VerticalSpacer.of20(),
          DefaultSlider(
              onConfirmation: () => Navigator.of(context).pop(true),
              title: context.loc?.globalApproveSlide)
        ],
      ),
    ];

    context.showBottomSheet(
        children: content,
        onDone: onApproved,
        extraIconColor: AppColors.sand,
        extraIcon: approveSheetInfo != null ? Icons.warning_amber : null,
        onExtraIconTap: () => context.showInfoSheet(approveSheetInfo ?? ''));
  }
}
