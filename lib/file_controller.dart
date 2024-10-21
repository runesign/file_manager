import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class FileController extends GetxController {
  var isDoubleColumn = false.obs;
  var leftPath = ''.obs;
  var rightPath = ''.obs;
  var focusedPane = true.obs;
  var isGridView = false.obs;
  var isLeftSelectionMode = false.obs;
  var isRightSelectionMode = false.obs;

  var leftSelectedItems = <String>{}.obs;
  var rightSelectedItems = <String>{}.obs;

  StreamSubscription<FileSystemEvent>? _leftWatcher;
  StreamSubscription<FileSystemEvent>? _rightWatcher;

  @override
  void onInit() async {
    super.onInit();
    final directory = await getApplicationDocumentsDirectory();
    leftPath.value = rightPath.value = directory.path;
    startWatching(directory.path, true);
    startWatching(directory.path, false);
  }

  bool hasSelectedItems() {
    return leftSelectedItems.isNotEmpty || rightSelectedItems.isNotEmpty;
  }

  void toggleLayout() {
    isDoubleColumn.value = !isDoubleColumn.value;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void navigateTo(String path, bool isLeftPane) {
    if (isLeftPane) {
      leftPath.value = path;
      leftSelectedItems.clear();
    } else {
      rightPath.value = path;
      rightSelectedItems.clear();
    }
    focusedPane.value = isLeftPane;
    startWatching(path, isLeftPane);
  }

  void toggleItemSelection(String path, bool isLeftPane) {
    final selectedItems = isLeftPane ? leftSelectedItems : rightSelectedItems;
    if (selectedItems.contains(path)) {
      selectedItems.remove(path);
    } else {
      selectedItems.add(path);
    }
    focusedPane.value = isLeftPane;
    update();
  }

  void deleteSelectedItems() {
    final selectedItems =
        focusedPane.value ? leftSelectedItems : rightSelectedItems;
    // final currentPath = focusedPane.value ? leftPath.value : rightPath.value;

    for (var path in selectedItems) {
      final file =
          FileSystemEntity.typeSync(path) == FileSystemEntityType.directory
              ? Directory(path)
              : File(path);
      file.deleteSync(recursive: true);
    }

    selectedItems.clear();
    refreshCurrentPane(focusedPane.value);
  }

  void renameSelectedItem(String newName) {
    final selectedItems =
        focusedPane.value ? leftSelectedItems : rightSelectedItems;
    if (selectedItems.length != 1) return;

    final oldPath = selectedItems.first;
    final directory = Directory(oldPath).parent;
    final newPath = '${directory.path}${Platform.pathSeparator}$newName';

    FileSystemEntity.typeSync(oldPath) == FileSystemEntityType.directory
        ? Directory(oldPath).renameSync(newPath)
        : File(oldPath).renameSync(newPath);

    selectedItems.clear();
    refreshCurrentPane(focusedPane.value);
  }

  void startWatching(String path, bool isLeftPane) {
    final watcher = isLeftPane ? _leftWatcher : _rightWatcher;
    watcher?.cancel();

    final newWatcher = Directory(path).watch().listen((event) {
      refreshCurrentPane(isLeftPane);
    });

    if (isLeftPane) {
      _leftWatcher = newWatcher;
    } else {
      _rightWatcher = newWatcher;
    }
  }

  void refreshCurrentPane(bool isLeftPane) {
    final currentPath = isLeftPane ? leftPath.value : rightPath.value;
    final selectedItems = isLeftPane ? leftSelectedItems : rightSelectedItems;

    // 保存当前选中的项目
    final currentSelectedItems = Set<String>.from(selectedItems);

    // 刷新当前路径
    navigateTo(currentPath, isLeftPane);

    // 恢复之前选中的项目（如果它们仍然存在）
    selectedItems.addAll(currentSelectedItems);

    // 清理不存在的选中项
    cleanupSelectedItems(isLeftPane);
  }

  void cleanupSelectedItems(bool isLeftPane) {
    // final currentPath = isLeftPane ? leftPath.value : rightPath.value;
    final selectedItems = isLeftPane ? leftSelectedItems : rightSelectedItems;

    selectedItems.removeWhere((path) {
      return !FileSystemEntity.isFileSync(path) &&
          !Directory(path).existsSync();
    });
  }

  void toggleSelectionMode(bool isLeftPane) {
    if (isLeftPane) {
      isLeftSelectionMode.value = !isLeftSelectionMode.value;
      if (!isLeftSelectionMode.value) {
        leftSelectedItems.clear();
      }
    } else {
      isRightSelectionMode.value = !isRightSelectionMode.value;
      if (!isRightSelectionMode.value) {
        rightSelectedItems.clear();
      }
    }
  }

  bool isAnySelectionModeActive() {
    return isLeftSelectionMode.value || isRightSelectionMode.value;
  }

  void selectAll() {
    final currentPath = focusedPane.value ? leftPath.value : rightPath.value;
    final files = Directory(currentPath).listSync();
    final selectedItems =
        focusedPane.value ? leftSelectedItems : rightSelectedItems;

    if (selectedItems.length == files.length) {
      selectedItems.clear();
    } else {
      selectedItems.clear();
      selectedItems.addAll(files.map((file) => file.path));
    }
  }

  void navigateUp() {
    final currentPath = focusedPane.value ? leftPath.value : rightPath.value;
    final parentPath = Directory(currentPath).parent.path;
    navigateTo(parentPath, focusedPane.value);
  }

  void createNew({required bool isFile, required String name}) {
    final currentPath = focusedPane.value ? leftPath.value : rightPath.value;
    String newPath = '$currentPath${Platform.pathSeparator}$name';

    int counter = 1;
    while (
        FileSystemEntity.typeSync(newPath) != FileSystemEntityType.notFound) {
      String newName = isFile ? '$name ($counter)' : '$name ($counter)';
      newPath = '$currentPath${Platform.pathSeparator}$newName';
      counter++;
    }

    if (isFile) {
      File(newPath).createSync();
    } else {
      Directory(newPath).createSync();
    }

    refreshCurrentPane(focusedPane.value);
  }

  @override
  void onClose() {
    _leftWatcher?.cancel();
    _rightWatcher?.cancel();
    super.onClose();
  }
}
