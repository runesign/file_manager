import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_controller.dart';

class PermanentBottomBar extends StatelessWidget {
  final FileController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelectionMode = controller.focusedPane.value
          ? controller.isLeftSelectionMode.value
          : controller.isRightSelectionMode.value;

      if (isSelectionMode) {
        return const SizedBox.shrink();
      }

      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.check_box_outline_blank),
              onPressed: () =>
                  controller.toggleSelectionMode(controller.focusedPane.value),
              tooltip: 'Selection Mode',
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                controller.toggleSelectionMode(controller.focusedPane.value);
                controller.selectAll();
              },
              tooltip: 'Select All',
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: () => _showCreateNewDialog(context),
              tooltip: 'New File/Folder',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () => controller.navigateUp(),
              tooltip: 'Up',
            ),
          ],
        ),
      );
    });
  }

  void _showCreateNewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: const Text('Create New'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: const InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('File'),
              onPressed: () {
                if (newName.isNotEmpty) {
                  controller.createNew(isFile: true, name: newName);
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: const Text('Folder'),
              onPressed: () {
                if (newName.isNotEmpty) {
                  controller.createNew(isFile: false, name: newName);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
