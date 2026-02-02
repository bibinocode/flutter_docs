import 'package:flutter/material.dart';
import 'package:get/get.dart';

// GetX Controller
class CounterController extends GetxController {
  var count = 0.obs;

  void increment() => count++;
  void decrement() => count--;
  void reset() => count.value = 0;
}

// 用户列表 Controller
class UsersController extends GetxController {
  var users = <String>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    users.value = ['Alice', 'Bob', 'Charlie', 'David'];
    isLoading.value = false;
  }
}

/// GetX 状态管理模块页面
class GetxPage extends StatelessWidget {
  const GetxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterController = Get.put(CounterController());
    final usersController = Get.put(UsersController());

    return Scaffold(
      appBar: AppBar(title: const Text('GetX 状态管理')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Obx 计数器',
              child: Column(
                children: [
                  Obx(() => Text('${counterController.count}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(onPressed: counterController.decrement, icon: const Icon(Icons.remove), label: const Text('减少')),
                      const SizedBox(width: 16),
                      FilledButton.icon(onPressed: counterController.increment, icon: const Icon(Icons.add), label: const Text('增加')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: counterController.reset, child: const Text('重置')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Obx 用户列表',
              child: Obx(() {
                if (usersController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: usersController.users
                      .map(
                        (name) => ListTile(
                          leading: CircleAvatar(child: Text(name[0])),
                          title: Text(name),
                        ),
                      )
                      .toList(),
                );
              }),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'GetX 特点',
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('✅ 简洁的响应式编程 (.obs)'), SizedBox(height: 8), Text('✅ 内置路由管理'), SizedBox(height: 8), Text('✅ 依赖注入 (Get.put/find)'), SizedBox(height: 8), Text('✅ 国际化支持'), SizedBox(height: 8), Text('✅ 工具类 (Snackbar, Dialog, BottomSheet)')]),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'GetX 工具演示',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(onPressed: () => Get.snackbar('提示', '这是一个 GetX Snackbar'), child: const Text('Snackbar')),
                  FilledButton.tonal(
                    onPressed: () => Get.defaultDialog(title: '对话框', middleText: '这是一个 GetX Dialog'),
                    child: const Text('Dialog'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => Get.bottomSheet(Container(color: Theme.of(context).colorScheme.surface, padding: const EdgeInsets.all(16), child: const Text('这是一个 GetX BottomSheet'))),
                    child: const Text('BottomSheet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ],
    );
  }
}
