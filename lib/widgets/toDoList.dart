import 'package:flutter/material.dart';
import './toDoListDetail.dart'; // 引入任务详情页面
import '../database/dataManager.dart'; // 引入Firestore服务
import 'package:firebase_auth/firebase_auth.dart';

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _currentUser = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  void _getCurrentUserName() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      Employee? employee = await _firestoreService.getEmployee(userId);
      if (employee != null) {
        setState(() {
          _currentUser = employee.name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('待办事项'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var tasks = snapshot.data ?? [];
          var filteredTasks =
              tasks.where((task) => task.responsible == _currentUser).toList();
          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              var task = filteredTasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: Text('${task.progress.toStringAsFixed(1)}%'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToDoListDetailPage(
                        id: task.id,
                        title: task.title,
                        details: task.description,
                        progress: task.progress,
                        issues: task.issues,
                        estimatedCompletion:
                            task.estimatedCompletionDate.toString(),
                        currentStatus: '进行中',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
