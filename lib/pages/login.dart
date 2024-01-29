import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/dataManager.dart';
import '../pages/home2.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance; // Firebase Authentication实例
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _login() async {
    try {
      // 使用邮箱和密码进行登录
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      // 登录成功后同步任务与日历事件
      await syncCalendarEventsWithTasks(_firestoreService);
      Navigator.pushNamed(context, '/home'); // 登录成功，跳转到主页
    } on FirebaseAuthException catch (e) {
      // 处理登录错误
      _showErrorDialog(e.message ?? '登录失败');
    }
  }

  // 管理员登录
  Future<void> _loginAsManager() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // 验证管理员
      Manager? manager = await _firestoreService.getManager(email);
      print(manager?.email);
      if (manager != null && manager?.hashedPassword == password) {
        // TODO: 进行管理员登录逻辑，比如跳转到管理员页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home2Page(managerEmail: manager.email),
          ),
        );
      } else {
        _showErrorDialog('管理员登录失败');
      }
    } catch (e) {
      _showErrorDialog('管理员登录出现错误');
    }
  }

// 同步任务到日历事件的逻辑
  Future<void> syncCalendarEventsWithTasks(
      FirestoreService firestoreService) async {
    // 获取所有任务
    List<Task> tasks = await firestoreService.getAllTasks();

    // 为每个任务创建或更新日历事件
    for (var task in tasks) {
      DateTime? taskDate = DateTime.tryParse(task.estimatedCompletionDate);

      // 如果解析成功，则创建日历事件；如果失败，则跳过
      if (taskDate != null) {
        CalendarEvent event = CalendarEvent(
          id: task.id, // 使用Task的ID作为CalendarEvent的ID
          date: taskDate,
          title: task.title,
          responsible: task.responsible,
        );

        // 更新或创建日历事件
        await firestoreService.setCalendarEvent(event, event.id);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('错误'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('好'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        // 添加 SingleChildScrollView
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '邮箱'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密码'),
              obscureText: true, // 密码隐藏
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('登录'),
              onPressed: _login, // 登录按钮调用_login方法
            ),
            ElevatedButton(
              child: Text('管理员登录'),
              onPressed: _loginAsManager,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('注册'),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}
