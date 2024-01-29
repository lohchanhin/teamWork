import 'package:flutter/material.dart';
import '../database/dataManager.dart'; // 引入Mission类

class MissionDetailPage extends StatelessWidget {
  final Mission mission; // 使用Mission对象

  MissionDetailPage({
    Key? key,
    required this.mission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用换行符'\n'分割难题字符串为列表
    List<String> challenges = mission.challenges[0].split('\\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(mission.title), // 显示任务标题
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle('任务标题'),
            Text(mission.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            buildSectionTitle('详细描述'),
            Text(mission.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            buildSectionTitle('可能的难题'),
            // 展示难题列表
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: challenges.asMap().entries.map((entry) {
                int idx = entry.key;
                String challenge = entry.value.trim(); // 去除字符串两端的空白字符
                return Text('${idx + 1}. $challenge');
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}
