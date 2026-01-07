## 状态码与错误处理 🐢 详细开销分析
- 1. 网络接收与字符串解码 (Main Thread)
操作：Dio 接收 TCP 流，并执行 utf8.decode 将二进制转为 Dart String。
开销：O(N)，N 为字节数。
评价：这是目前链路中唯一还留在主线程的重逻辑。
对于普通数据（<100KB），耗时忽略不计（<1ms）。
对于超大数据（>5MB），utf8.decode 可能会占用主线程 10-20ms，导致轻微掉帧。
极致优化方案：如果这里都要优化，需要使用 Transformer 在后台 Isolate 进行 utf8.decode，或者直接把 Uint8List 传给 Worker（需 Sanitizer 库支持 Bytes 输入）。

- 2. 跨 Isolate 传输 (Main -> Worker)
操作：将巨大的 JSON String 从主 Isolate 发送给 Worker Isolate。
开销：内存拷贝开销。
评价：Dart 在 isolate 间传递 String 通常需要拷贝内存。
耗时与 String 长度成正比。但通常比 JSON 解析快得多。
优化：如果使用 TransferableTypedData，可以实现“零拷贝”传输（JsonSanitizer 库内部有优化机制，如果是 String 往往会自动处理，或者建议传入 Bytes）。

- 3. JSON 解析 (Worker Isolate) 🚀 (核心收益区)
操作：jsonDecode(String)。
开销：极高。这是整个链路中最耗 CPU 的步骤。包含词法分析、对象创建等。
评价：Zero Cost to UI。无论这里耗时 100ms 还是 1s，主线程动画依然如丝般顺滑。这是本方案的最大价值。

- 4. 数据清洗与信封解包 (Worker Isolate)
操作：根据 Schema 遍历 Map，检查类型，提取 data 节点。
开销：取决于 Schema 的复杂度，通常低于 jsonDecode。
评价：Zero Cost to UI。我们在 Worker 里完成了 data 的提取，避免了“先在主线程解包 -> 再丢给 Worker”的双重开销。

- 5. 结果回传 (Worker -> Main)
操作：将清洗后的干净 Map 传回主线程。
开销：结构化克隆 (Deep Copy)。
评价：Dart VM 需要把整个 Map 对象图从 Worker 堆里复制到 Main 堆里。
耗时与数据对象的节点数量成正比。
这是一个无法避免的物理开销（除非 Dart 支持 Shared Memory 对象）。

- 6. 模型构建 (Main Thread)
操作：User.fromJson(map)。
开销：O(K)，K 为对象字段数。
评价：极低。由于 Map 已经在 Worker 里生成好了，这里只是简单的“指针赋值”和“对象头分配”。
相比于 jsonDecode，fromJson 的速度快一个数量级。
不会引起掉帧。


## 性能评级：
![alt text](image.png)