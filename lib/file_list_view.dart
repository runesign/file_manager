import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_controller.dart';
import 'dart:io';

class FileListView extends StatelessWidget {
  final bool isLeftPane;
  final FileController controller = Get.find();

  FileListView({required this.isLeftPane});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        controller.focusedPane.value = isLeftPane;
      },
      onPanDown: (details) {
        controller.focusedPane.value = isLeftPane;
      },
      child: Obx(() {
        final currentPath =
            isLeftPane ? controller.leftPath.value : controller.rightPath.value;
        final files = Directory(currentPath).listSync();
        final isFocused = controller.focusedPane.value == isLeftPane;

        // 确保当前路径被监控
        controller.startWatching(currentPath, isLeftPane);

        return Column(
          children: [
            _buildBreadcrumb(currentPath),
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return _buildFileItem(file, isFocused);
                },
              ),
            ),
          ],
        );
      }),
    );
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

      return ListTile(
        leading: Icon(isDirectory ? Icons.folder : Icons.insert_drive_file),
        title: Text(
          name,
          style: TextStyle(color: isFocused ? Colors.black : Colors.black54),
        ),
        selected: isSelected,
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
      );
    });
  }
}
