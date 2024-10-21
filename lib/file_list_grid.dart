import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_controller.dart';
import 'dart:io';

class FileListGrid extends StatelessWidget {
  final bool isLeftPane;
  final FileController controller = Get.find();

  FileListGrid({required this.isLeftPane});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPath =
          isLeftPane ? controller.leftPath.value : controller.rightPath.value;
      final files = Directory(currentPath).listSync();
      final isFocused = controller.focusedPane.value == isLeftPane;

      controller.startWatching(currentPath, isLeftPane);

      return Column(
        children: [
          _buildBreadcrumb(currentPath),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileItem(file, isFocused);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBreadcrumb(String path) {
    final parts = path.split(Platform.pathSeparator);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: parts.map((part) {
          return TextButton(
            child: Text(part),
            onPressed: () => controller.navigateTo(
                parts
                    .take(parts.indexOf(part) + 1)
                    .join(Platform.pathSeparator),
                isLeftPane),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity file, bool isFocused) {
    final isDirectory = file is Directory;
    final name = file.path.split(Platform.pathSeparator).last;
    final selectedItems = isLeftPane
        ? controller.leftSelectedItems
        : controller.rightSelectedItems;

    return Obx(() {
      final isSelected = selectedItems.contains(file.path);

      return GestureDetector(
        onTap: () {
          if (isLeftPane
              ? controller.isLeftSelectionMode.value
              : controller.isRightSelectionMode.value) {
            controller.toggleItemSelection(file.path, isLeftPane);
          } else {
            if (isDirectory) {
              controller.navigateTo(file.path, isLeftPane);
            } else {
              // TODO: Open file
              print('Open file: $name');
            }
          }
        },
        onLongPress: () {
          if (!(isLeftPane
              ? controller.isLeftSelectionMode.value
              : controller.isRightSelectionMode.value)) {
            controller.toggleSelectionMode(isLeftPane);
          }
          controller.toggleItemSelection(file.path, isLeftPane);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent),
            color:
                isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDirectory ? Icons.folder : Icons.insert_drive_file,
                size: 40,
                color: isFocused ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isFocused ? Colors.black : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
