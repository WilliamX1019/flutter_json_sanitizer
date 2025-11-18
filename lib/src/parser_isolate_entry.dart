import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_json_sanitizer/src/json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

import 'model_registry.dart';
// 流程图
// 主 Isolate          |         Worker Isolate 的“信箱” (FIFO 队列)          |       Worker Isolate 的执行逻辑
// --------------------|-------------------------------------------------------|-------------------------------------------
// send(task1)  -----> | [task1]                                               |
// send(task2)  -----> | [task1, task2]                                        |
// send(task3)  -----> | [task1, task2, task3]                                 |
//                     |                                                       | (Worker 正在打盹...)
//                     |                                                       |
//                     | (新消息到达，Worker 被唤醒)                             |
//                     | [task2, task3] (task1 被取出)                         | ----> 开始处理 task1
//                     |                                                       |       ... (清洗 task1 的数据)
//                     |                                                       |       ... (发送 task1 的结果)
//                     |                                                       | (处理 task1 完毕，回到循环开头)
//                     |                                                       |
//                     | [task3] (task2 被取出)                                | ----> 开始处理 task2
//                     |                                                       |       ... (清洗 task2 的数据)
//                     |                                                       |       ... (发送 task2 的结果)
//                     |                                                       | (处理 task2 完毕，回到循环开头)
//                     |                                                       |
//                     | [] (task3 被取出)                                     | ----> 开始处理 task3
//                     |                                                       |       ...
//                     |                                                       | (处理 task3 完毕，回到循环开头)
//                     |                                                       |
//                     |                                                       | (信箱空了，Worker 再次开始打盹...)
/// 并发安全:
// 没有竞争条件 (Race Conditions): 由于Isolate是单线程的，您永远不需要担心多个任务会同时访问或修改某个共享状态（比如一个共享变量）。每个任务的处理过程都是原子性的、不受干扰的。
// 保证顺序: 消息队列保证了任务是按照它们被send的顺序来处理的。
// 无需锁 (No Locks Needed): 您不需要使用Mutex、Semaphore或任何其他传统的并发同步机制。Dart的Isolate模型从根本上消除了这类复杂性。

/// 长期驻留的 Isolate 的入口点。
/// Worker Isolate的入口函数（带心跳响应）
/// 
Future<void> parserIsolateEntryWithHeartbeat(SendPort mainPort) async {
  final workerPort = ReceivePort(); 
  mainPort.send(workerPort.sendPort);
  // 主任务循环
  await for (final message in workerPort) {
    if (message is ParseAndModelTask) {
      // 负责JSON清洗和模型创建
      try {
        // 0 拷贝接收 bytes
        final Uint8List rawBytes =
            message.jsonBytes.materialize().asUint8List();
        final Map<String, dynamic> jsonData =
            json.decode(utf8.decode(rawBytes));
        // 清洗数据  
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: message.schema,
          modelType: message.type,
        );
        final sanitizedJson = sanitizer.processMap(jsonData);
        ModelRegistry.register(message.type, message.fromJson, isSubIsolate: true);
        // 动态创建模型实例
        final model = ModelRegistry.create(message.type, sanitizedJson,isSubIsolate: true);

        if (model != null) {
          // 返回模型实例
          message.replyPort.send(ParseResult.success(model, sanitizedJson));
        } else {
          message.replyPort.send(ParseResult.failure(
              Exception("Model creation failed for ${message.type}"),null));
        }
      } catch (e, s) {
        message.replyPort.send(ParseResult.failure(e, s));
      }
    }
  }
}
