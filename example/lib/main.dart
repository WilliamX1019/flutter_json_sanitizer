import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

import 'models/user_profile.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // --- 2. 在应用启动时，初始化Worker ---
  try{
    print('初始化Worker... ${DateTime.now().millisecondsSinceEpoch}');
    await JsonParserWorker.instance.initialize();
    print('Worker初始化完成... ${DateTime.now().millisecondsSinceEpoch}');
  } catch(e) {
    print('初始化Worker失败... $e');
    print("FATAL: JsonParserWorker could not be initialized. App functionality will be degraded.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = '开始净化脏数据';
  //定义脏数据
  // final dirtyJson = {
  //   "user_id": "9981",
  //   "name": 12345,
  //   "is_active": "1",
  //   "tags": [10, "flutter", true, null],
  //   "permissions": {"read": "1", "write": 0, "admin": null},
  //   "mainProduct": {
  //     "product_id": 101.0,
  //     "name": ["My Awesome Product"]
  //   },
  //   "metadata": [], // 关键测试点: 空列表应被转换为空Map
  // };
final dirtyJson = {
    "user_id": "9981",
    "name": null, // <-- 这是一个明确的 null 值
    "is_active": "1",
    "tags": ["a", "b" ,null],
    "permissions": {},
    "mainProduct": {"product_id": 101, "name": "Book"},
    "metadata": [],
  };
  void _incrementCounter() {
    // 2. 核心操作：使用JsonSanitizer和自动生成的公开Schema变量进行清洗
//     final sanitizedJson = JsonSanitizer.sanitize(
//         dirtyJson, $UserProfileSchema); // <-- 使用公开的 $...Schema 变量

// // 3. 最终验证：使用清洗后的JSON创建模型实例
//     final userProfile = UserProfile.fromJson(sanitizedJson);
//     print('清洗后的JSON: $userProfile');
// // 4. 格式化输出，以便在UI上清晰地展示对比结果
//     const jsonEncoder = JsonEncoder.withIndent('  ');
//     final formattedOriginal = jsonEncoder.convert(dirtyJson);
//     final formattedSanitized = jsonEncoder.convert(sanitizedJson);

//       print('原始JSON: $formattedOriginal');
//       print('净化后的JSON: $formattedSanitized');
//     if (formattedOriginal != formattedSanitized) {
//       setState(() {
//         title = '净化完成';
//       });
//     } else {
//       setState(() {
//         title = '净化未完成';
//       });
//     }

    //同步解析
    // final profile = JsonSanitizer.parse<UserProfile>(
    //   data: dirtyJson,
    //   schema: $UserProfileSchema,
    //   fromJson: UserProfile.fromJson,
    //   modelName: 'UserProfile',
    //   onIssuesFound: ({required issues, required modelName}) {
    //     print('发现问题: $issues 在模型 $modelName 中');
    //   },
    // );
    // print('解析后的模型: ${jsonEncode(profile)}');

    parseAsync();
  }

  void parseAsync() async {

    JsonSanitizer.validate(
      data: dirtyJson,
      schema: $UserProfileSchema,
      modelName: 'UserProfile',
      onIssuesFound: ({required issues, required modelName}) {
        print(
            'JsonSanitizer.validate 同步 在模型 $modelName 中 发现问题: $issues dirtyJson = $dirtyJson');
      },
    );

    final profile = await JsonSanitizer.parseAsync<UserProfile>(
      data: dirtyJson,
      schema: $UserProfileSchema,
      fromJson: UserProfile.fromJson,
      modelName: 'UserProfile',
      monitoredKeys: ['name'], // 我们明确告诉它要监控'name'字段
      onIssuesFound: ({required issues, required modelName}) {
        print('异步 发现问题: $issues 在模型 $modelName 中 , dirtyJson $dirtyJson');
       
      },
    );
    print('异步 解析后的模型: ${jsonEncode(profile)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
