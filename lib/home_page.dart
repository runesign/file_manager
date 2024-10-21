import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_list_view.dart';
import 'file_list_grid.dart';
import 'file_controller.dart';
import 'bottom_action_bar.dart';
import 'permanent_bottom_bar.dart';

class HomePage extends StatelessWidget {
  final FileController controller = Get.put(FileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件管理器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda),
            onPressed: controller.toggleLayout,
          ),
          IconButton(
            icon: Obx(() => Icon(
                controller.isGridView.value ? Icons.list : Icons.grid_view)),
            onPressed: controller.toggleViewMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              Widget fileList(bool isLeftPane) {
                return controller.isGridView.value
                    ? FileListGrid(isLeftPane: isLeftPane)
                    : FileListView(isLeftPane: isLeftPane);
              }

              return controller.isDoubleColumn.value
                  ? Row(
                      children: [
                        Expanded(child: fileList(true)),
                        Expanded(child: fileList(false)),
                      ],
                    )
                  : fileList(true);
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        bool isSelectionMode = controller.focusedPane.value
            ? controller.isLeftSelectionMode.value
            : controller.isRightSelectionMode.value;

        return isSelectionMode ? BottomActionBar() : PermanentBottomBar();
      }),
    );
  }
}
