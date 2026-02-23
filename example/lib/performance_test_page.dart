// ignore_for_file: implementation_imports, library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/json_sanitizer.dart'; // 需要内部API来实现同步解析
import 'models/列表测试/product_list_json.dart';
import 'models/列表测试/product_list_model.dart';
// 如果没有到处 $ProductListModelSchema 这个需要 import 'models/列表测试/product_list_model.dart' 或者类似的位置

class PerformanceTestPage extends StatefulWidget {
  const PerformanceTestPage({Key? key}) : super(key: key);

  @override
  _PerformanceTestPageState createState() => _PerformanceTestPageState();
}

class _PerformanceTestPageState extends State<PerformanceTestPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _fps = 0;
  int _frameCount = 0;
  Duration? _lastElapsed;

  String _status = "闲置状态";
  int _iterations = 50; // 根据性能自己调节
  late final String _hugeJsonString;

  @override
  void initState() {
    super.initState();
    _hugeJsonString = jsonEncode(productListModelJson);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (!mounted) return;
      if (_lastElapsed != null) {
        final diff = timeStamp.inMilliseconds - _lastElapsed!.inMilliseconds;
        if (diff >= 1000) {
          setState(() {
            _fps = _frameCount;
          });
          _frameCount = 0;
          _lastElapsed = timeStamp;
        } else {
          _frameCount++;
        }
      } else {
        _lastElapsed = timeStamp;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // A 组：子常驻 isolate 中进行
  Future<void> _runTestA() async {
    setState(() {
      _status = "A组（Worker Isolate）运行中...";
    });
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      await JsonSanitizer.parseAsync<ProductListModel>(
        data: productListModelJson,
        schema: $ProductListModelSchema,
        fromJson: ProductListModel.fromJson,
        modelType: ProductListModel,
      );
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "A组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }

  // B 组：Main Isolate 中进行
  Future<void> _runTestB() async {
    setState(() {
      _status = "B组（Main Isolate）运行中...";
    });
    // 使用 Future.delayed 让 UI 刷新一下状态
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      // 由于没有暴露官方的 parseSync, 我们手动组合验证和清洗逻辑
      final isValid = JsonSanitizer.validate(
        data: productListModelJson,
        schema: $ProductListModelSchema,
        modelType: ProductListModel,
      );
      if (isValid) {
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: $ProductListModelSchema,
          modelType: ProductListModel,
        );
        final sanitizedData = sanitizer.processMap(productListModelJson);
        ProductListModel.fromJson(sanitizedData);
      }
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "B组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }

  // C 组：纯 Isolate (compute) JSON Decode 测试
  Future<void> _runTestC() async {
    setState(() {
      _status = "C组（Compute 子 Isolate）纯解析中...";
    });
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      await compute(jsonDecode, _hugeJsonString);
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "C组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }

  // D 组：Main Isolate 纯 JSON Decode 测试
  Future<void> _runTestD() async {
    setState(() {
      _status = "D组（Main Isolate）纯解析中...";
    });
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      jsonDecode(_hugeJsonString);
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "D组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('性能对比: Isolate vs 主线程'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "性能测试：连续解析复杂的列表型 JSON 数据多遍。观察执行时的帧率变化和动画卡顿情况。",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("当前 FPS",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("$_fps",
                          style: TextStyle(
                              fontSize: 32,
                              color: _fps < 40 ? Colors.red : Colors.green)),
                    ],
                  ),
                  RotationTransition(
                    turns: _animationController,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Icon(Icons.sync, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "状态: $_status",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _runTestA,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100]),
                  child: const Text('A组: 全链路(Worker)'),
                ),
                ElevatedButton(
                  onPressed: _runTestB,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100]),
                  child: const Text('B组: 全链路(Main)'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _runTestC,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[100]),
                  child: const Text('C组: 纯Decode(Isolate)'),
                ),
                ElevatedButton(
                  onPressed: _runTestD,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100]),
                  child: const Text('D组: 纯Decode(Main)'),
                ),
              ],
            ),
            const Spacer(),
            Text(
                "说明: Worker Isolate 能保证 UI(FPS) 流畅, 且由于 Flutter 3+ 优化,  isolate 开销大大降低。"),
          ],
        ),
      ),
    );
  }
}
