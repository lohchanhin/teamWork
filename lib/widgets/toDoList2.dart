import 'package:flutter/material.dart';
import '../database/dataManager.dart';
import './toDoListDetail.dart';

class ToDoList2Page extends StatefulWidget {
  @override
  _ToDoList2PageState createState() => _ToDoList2PageState();
}

class _ToDoList2PageState extends State<ToDoList2Page> {
  final FirestoreService _firestoreService = FirestoreService();
  Employee? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务列表'),
        automaticallyImplyLeading: false,
      ),
      body: _selectedEmployee == null
          ? StreamBuilder<List<Employee>>(
              stream: _firestoreService.getEmployeesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('发生错误: ${snapshot.error}'));
                }
                List<Employee> employees = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    Employee employee = employees[index];
                    return ListTile(
                      title: Text(employee.name),
                      onTap: () => setState(() => _selectedEmployee = employee),
                    );
                  },
                );
              },
            )
          : FutureBuilder<List<Task>>(
              future: _firestoreService.getAllTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('发生错误: ${snapshot.error}'));
                }
                List<Task> tasks = snapshot.data
                        ?.where((task) =>
                            task.responsible == _selectedEmployee!.name)
                        .toList() ??
                    [];
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Task task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text('进度: ${task.progress}%'),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () async {
                          await _firestoreService.deleteTask(task.id);
                          await _firestoreService.deleteCalendarEvent(task.id);
                          setState(() {});
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToDoListDetailPage(
                            id: task.id,
                            title: task.title,
                            details: task.description,
                            progress: task.progress,
                            issues: task.issues,
                            estimatedCompletion: task.estimatedCompletionDate,
                            currentStatus: '进行中',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
