import 'package:flutter/material.dart';
import '../database/dataManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // 引入 uuid 库

class Mission2Page extends StatefulWidget {
  @override
  _Mission2PageState createState() => _Mission2PageState();
}

class _Mission2PageState extends State<Mission2Page> {
  final FirestoreService _firestoreService = FirestoreService();
  var uuid = Uuid(); // 创建 Uuid 实例
  void _showEditMissionDialog(Mission? mission) async {
    final _titleController = TextEditingController(text: mission?.title);
    final _descriptionController =
        TextEditingController(text: mission?.description);
    final _challengesController =
        TextEditingController(text: mission?.challenges.join('\n'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mission == null ? '添加任务' : '编辑任务'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: '标题'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: '描述'),
                ),
                TextField(
                  controller: _challengesController,
                  decoration: InputDecoration(labelText: '难题'),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () async {
                String missionId = mission?.id ?? uuid.v4(); // 如果是新任务，则生成新的 ID
                // 创建或更新Mission对象
                Mission updatedMission = Mission(
                  id: missionId,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  challenges: _challengesController.text.split('\n'),
                );
                await _firestoreService.setMission(updatedMission);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            if (mission != null)
              TextButton(
                child: Text('删除'),
                onPressed: () async {
                  await _firestoreService.deleteMission(mission.id);
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('任务管理'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Mission>>(
        stream: _firestoreService.getMissionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('发生错误: ${snapshot.error}'));
          }
          List<Mission> missions = snapshot.data ?? [];
          return ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, index) {
              Mission mission = missions[index];
              return ListTile(
                title: Text(mission.title),
                onTap: () => _showEditMissionDialog(mission),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditMissionDialog(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
