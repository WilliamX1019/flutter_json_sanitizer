import 'dart:convert';

import 'package:example/models/%E5%88%97%E8%A1%A8%E6%B5%8B%E8%AF%95/product_list_model.dart';
import 'package:example/models/%E5%A4%9A%E5%B1%82%E5%B5%8C%E5%A5%97%E6%B5%8B%E8%AF%95/product_model.dart';
import 'package:example/models/%E5%A4%9A%E5%B1%82%E5%B5%8C%E5%A5%97%E6%B5%8B%E8%AF%95/product_model_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

import 'models/user_profile.dart';
import 'models/列表测试/product_list_json.dart';
import 'utils/safe_extensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // --- 2. 在应用启动时，初始化Worker ---
  try {
    print('初始化Worker... ${DateTime.now().millisecondsSinceEpoch}');
    await JsonParserWorker.instance.initialize();
    print('Worker初始化完成... ${DateTime.now().millisecondsSinceEpoch}');
  } catch (e) {
    print('初始化Worker失败... $e');
    print(
        "FATAL: JsonParserWorker could not be initialized. App functionality will be degraded.");
  }
  print(
      'JsonParserWorker health... ${JsonParserWorker.instance.isInitialized}');
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
  bool isInitialized = false;
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
    "tags": ["a", "b", null],
    "permissions": {},
    "mainProduct": {"product_id": '101', "name": "Book"},
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
      modelType: UserProfile,
      onIssuesFound: ({required issues, required modelType}) {
        print(
            'JsonSanitizer.validate 同步 在模型 $modelType 中 发现问题: $issues dirtyJson = $dirtyJson');
      },
    );

    final profile = await JsonSanitizer.parseAsync<UserProfile>(
      data: dirtyJson,
      schema: $UserProfileSchema,
      fromJson: UserProfile.fromJson,
      modelType: UserProfile,
      monitoredKeys: ['name'], // 我们明确告诉它要监控'name'字段
      onIssuesFound: ({required issues, required modelType}) {
        print('异步 发现问题: $issues 在模型 $modelType 中 , dirtyJson $dirtyJson');
      },
    );
    print('异步 解析后的模型: ${jsonEncode(profile)}');

    // --- 演示通用安全扩展方法的使用 ---
    if (profile != null) {
      print('Generic Safe Access Demo:');
      // String? -> String
      print('Name: ${profile.name.orEmpty}');
      // int? -> int
      print('UserID: ${profile.userId.orZero}');
      // bool? -> bool
      print('Is Active: ${profile.isActive.orFalse}');
      // List? -> List
      print('Tags Count: ${profile.tags.orEmpty.length}');

      // 链式调用: 如果对象本身可能为null，可以结合 ?. 使用
      // 注意：对于自定义对象（如Permissions），仍然需要判空，或者为自定义对象也写通用的 orEmpty (需要单例或工厂)
      // 但针对基本类型字段，直接用 .orZero / .orEmpty 即可
      print('Permissions Read: ${profile.permissions?.read.orZero}');
    }
  }

  ///多层嵌套数据的净化
  void _sanitizeNestedJson() async {
    print('ProductModelSchema = ${$ProductModelSchema}');
    final model = await JsonSanitizer.parseAsync<ProductModel>(
      data: productModelJson,
      schema: $ProductModelSchema,
      fromJson: ProductModel.fromJson,
      modelType: ProductModel,
      onIssuesFound: ({required issues, required modelType}) {
        print('异步 发现问题: $issues 在模型 $modelType 中');
      },
    );
    print('ProductModel : ${model?.id}');
    if (JsonParserWorker.instance.isInitialized) {
      setState(() {
        isInitialized = true;
      });
    }
  }

  void _sanitizeListNestedJson() async {
    print('ProductListModelSchema = ${$ProductListModelSchema}');
    final model = await JsonSanitizer.parseAsync<ProductListModel>(
      data: productListModelJson,
      schema: $ProductListModelSchema,
      fromJson: ProductListModel.fromJson,
      modelType: ProductListModel,
      onIssuesFound: ({required issues, required modelType}) {
        // print('异步 发现问题: $issues 在模型 $modelType 中');
      },
    );
    final length = model?.list?.orEmpty.length;

    // print('ProductModel : ${model?.list?.length}');
    if (JsonParserWorker.instance.isInitialized) {
      setState(() {
        isInitialized = true;
      });
    }
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
            ElevatedButton(
              onPressed: () {
                _sanitizeNestedJson();
              },
              child: const Text('净化多层嵌套数据'),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                _sanitizeListNestedJson();
              },
              child: const Text('净化列表多层嵌套数据'),
            ),
            Text('当前Worker状态: ${JsonParserWorker.instance.isInitialized}')
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
