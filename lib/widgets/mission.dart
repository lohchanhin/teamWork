import 'package:flutter/material.dart';
import './missionDetail.dart';
import '../database/dataManager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MissionPage extends StatefulWidget {
  @override
  _MissionPageState createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  final FirestoreService _firestoreService = FirestoreService();

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
                trailing: ElevatedButton(
                  child: Text('领取'),
                  onPressed: () async {
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    Employee? employee =
                        await _firestoreService.getEmployee(userId);

                    if (employee != null) {
                      Task newTask = Task(
                        id: mission.id, // 使用Mission的ID
                        title: mission.title,
                        description: mission.description,
                        progress: 0, // 初始进度为0
                        issues: '', // 初始无问题
                        estimatedCompletionDate:
                            DateTime.now().toIso8601String(), // 设置为当前日期
                        responsible: employee.name, // 使用Employee的名字作为负责人
                      );

                      CalendarEvent newCalendarEvent = CalendarEvent(
                          id: mission.id,
                          date: DateTime.now(),
                          title: mission.title,
                          responsible: employee.name);
                      // 添加任务到Firestore
                      _firestoreService.setTask(newTask);

                      _firestoreService.setCalendarEvent(
                          newCalendarEvent, mission.id);
                      // 可选：从Missions中删除该任务
                      _firestoreService.deleteMission(mission.id);

                      // 更新UI
                      setState(() {});
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MissionDetailPage(mission: mission),
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
