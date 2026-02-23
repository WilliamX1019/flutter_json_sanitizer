// ignore_for_file: implementation_imports, library_private_types_in_public_api
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/json_transferable_utils.dart';
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
  int _iterations = 100; // 根据性能自己调节
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
        onIssuesFound: ({required issues, required modelType}) {
          print("A组: modelType: $modelType ,issues: $issues");
        },
      );
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "A组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }

  // A1 组：Worker Isolate 模拟网络原始数据（优化性能）
  // 模拟从 Dio/HttpClient 等拿到的原始 Response Bytes，直接进行0拷贝传输。
  Future<void> _runTestA1() async {
    setState(() {
      _status = "A1 组（0拷贝模拟）运行中...";
    });
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      // 这里的 data 必须是 TransferableTypedData
      // JsonTransferableUtils.encode 其实内部也是做 jsonString->Byte的操作
      final transferableData = JsonTransferableUtils.encode(_hugeJsonString);
      await JsonSanitizer.parseAsync<ProductListModel>(
        data: transferableData,
        schema: $ProductListModelSchema,
        fromJson: ProductListModel.fromJson,
        modelType: ProductListModel,
        onIssuesFound: ({required issues, required modelType}) {
          print("A1组: modelType: $modelType ,issues: $issues");
        },
      );
    }
    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "A1 组完成: 耗时 $cost ms ($_iterations 次)";
    });
  }
  // B 组：Main Isolate 中进行 (复用库内嵌的主线程兜底运行机制)
  Future<void> _runTestB() async {
    setState(() {
      _status = "B组（Main Isolate）运行中...";
    });
    // 使用 Future.delayed 让 UI 刷新一下状态
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    // 核心步骤：通过 dispose 停用子 Isolate 以触发底层的 Fallback 检测
    // 让其被迫退守走在 Main Isolate 中的清洗运行
    final worker = JsonParserWorker.instance;
    final wasInitialized = worker.isInitialized;
    if (wasInitialized) {
      worker.dispose();
    }

    try {
      for (int i = 0; i < _iterations; i++) {
        // 由于 worker.isInitialized 为 false，
        // parseAsync 内部自动分流走到主线（Fallback）的 parseAndSanitize 逻辑
        await JsonSanitizer.parseAsync<ProductListModel>(
          data: productListModelJson,
          schema: $ProductListModelSchema,
          fromJson: ProductListModel.fromJson,
          modelType: ProductListModel,
          onIssuesFound: ({required issues, required modelType}) {
            print("B组: modelType: $modelType ,issues: $issues");
          },
        );
      }
    } finally {
      // 执行完毕后，如果是刻意停掉的则重启保障后续功能
      if (wasInitialized) {
        await worker.initialize();
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

  // E 组：完整链路 (Worker 内置 Decoder)
  // 将 JSON 字符串直接传递给 parseAsync，使其在常驻子 Isolate 中同时进行 JSON decode 和数据清洗。
  Future<void> _runTestE() async {
    setState(() {
      _status = "E组（Worker Decode+Sanitize）运行中...";
    });
    await Future.delayed(const Duration(milliseconds: 100));
    final startTime = DateTime.now();

    for (int i = 0; i < _iterations; i++) {
      // 这里的 data 我们传入的是 String 类型的 _hugeJsonString
      // 根据 JsonParserWorker 的逻辑，传入 String 会直接被发送到 worker，然后在 worker 里进行解码及后续操作
      await JsonSanitizer.parseAsync<ProductListModel>(
        data: _hugeJsonString,
        schema: $ProductListModelSchema,
        fromJson: ProductListModel.fromJson,
        modelType: ProductListModel,
        onIssuesFound: ({required issues, required modelType}) {
          print("E组: modelType: $modelType ,issues: $issues");
        },
      );
    }

    final cost = DateTime.now().difference(startTime).inMilliseconds;
    setState(() {
      _status = "E组完成: 耗时 $cost ms ($_iterations 次)";
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
              "测试：连续解析复杂的列表型 JSON 数据多遍。观察执行时的帧率变化和动画卡顿情况。",
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
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
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
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestA,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100]),
                    child: const Text('A组: 全链路(Worker)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestA1,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[200]),
                    child: const Text('A1组: 网络0拷贝(TransferableTypedData)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestB,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[100]),
                    child: const Text('B组: 全链路(Main)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestC,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[100]),
                    child: const Text('C组: 纯Decode(Isolate)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestD,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[100]),
                    child: const Text('D组: 纯Decode(Main)'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _runTestE,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[100]),
                    child: const Text('E组: 全链路(Worker Decode)'),
                  ),
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
