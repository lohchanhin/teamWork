import 'package:flutter/material.dart';
import '../database/dataManager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToDoListDetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String details;
  final int progress;
  final String issues;
  final String estimatedCompletion;
  final String currentStatus;

  ToDoListDetailPage({
    Key? key,
    required this.id,
    required this.title,
    required this.details,
    required this.progress,
    required this.issues,
    required this.estimatedCompletion,
    required this.currentStatus,
  }) : super(key: key);

  @override
  _ToDoListDetailPageState createState() => _ToDoListDetailPageState();
}

class _ToDoListDetailPageState extends State<ToDoListDetailPage> {
  late int _progressValue;
  late TextEditingController _issuesController;
  late DateTime _estimatedCompletionDate;
  String _responsible = ""; // 负责人名称
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _progressValue = widget.progress;
    _issuesController = TextEditingController(text: widget.issues);
    _estimatedCompletionDate =
        DateTime.parse(widget.estimatedCompletion); // 使用传入的日期字符串
    _getCurrentUser(); // 获取当前用户信息
  }

  void _getCurrentUser() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      Employee? employee = await _firestoreService.getEmployee(userId);
      if (employee != null) {
        setState(() {
          _responsible = employee.name; // 设置负责人名称
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _estimatedCompletionDate, // 当前选定的日期
      firstDate: DateTime(2000), // 可选择的最早日期
      lastDate: DateTime(2025), // 可选择的最晚日期
    );
    if (picked != null && picked != _estimatedCompletionDate) {
      setState(() {
        _estimatedCompletionDate = picked; // 更新选定的日期
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // 显示任务标题
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('任务标题: ${widget.title}'), // 不可编辑
            SizedBox(height: 8),
            Text('任务描述: ${widget.details}'), // 不可编辑
            SizedBox(height: 16),
            Text('任务进度: ${_progressValue}%'),
            Slider(
              value: _progressValue.toDouble(),
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: '$_progressValue%',
              onChanged: (double value) {
                setState(() {
                  _progressValue = value.round();
                });
              },
            ),
            TextFormField(
              controller: _issuesController,
              decoration: InputDecoration(labelText: '当前所遇问题'),
              maxLines: null,
            ),
            ListTile(
              title: Text(
                  '预计完成时间: ${_estimatedCompletionDate.toLocal().toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Task updatedTask = Task(
                  id: widget.id,
                  title: widget.title,
                  description: widget.details,
                  progress: _progressValue,
                  issues: _issuesController.text,
                  estimatedCompletionDate:
                      _estimatedCompletionDate.toIso8601String(),
                  responsible: _responsible,
                );
                CalendarEvent updatedCalendarEvent = CalendarEvent(
                    id: widget.id,
                    date: _estimatedCompletionDate,
                    title: widget.title,
                    responsible: _responsible);
                await _firestoreService.updateTask(updatedTask);
                await _firestoreService
                    .updateCalendarEvent(updatedCalendarEvent);
                Navigator.pop(context);
              },
              child: Text('提交修改'),
            ),
          ],
        ),
      ),
    );
  }
}
