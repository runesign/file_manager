import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_controller.dart';

@override
class BottomActionBar extends StatelessWidget {
  final FileController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消选中按钮
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.toggleSelectionMode(controller.focusedPane.value);
            },
          ),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: controller.deleteSelectedItems,
          ),
          // 重命名按钮
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 假设你有一个重命名对话框
              showDialog(
                context: context,
                builder: (context) {
                  String newName = '';
                  return AlertDialog(
                    title: const Text('Rename'),
                    content: TextField(
                      onChanged: (value) {
                        newName = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Rename'),
                        onPressed: () {
                          controller.renameSelectedItem(newName);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
