import 'package:flutter/material.dart';
import '../widgets/persona.dart'; // 确保正确引入 PersonaDrawer
import '../widgets/mission.dart';
import '../widgets/Calendar.dart';
import '../widgets/toDoList.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Offset fabPosition = Offset(20.0, 20.0); // 浮动按钮的初始位置
  int _currentIndex = 0; // 当前选中的索引
  final List<Widget> _children = [
    MissionPage(),
    CalendarPage(),
    ToDoListPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: PersonaDrawer(), // 使用PersonaDrawer，不再传递currentUser信息
      body: Stack(
        children: [
          _children[_currentIndex], // 当前选中的页面
          Positioned(
            left: fabPosition.dx,
            top: fabPosition.dy,
            child: Draggable(
              child: FloatingActionButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                child: Icon(Icons.person),
              ),
              feedback: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.person),
              ),
              childWhenDragging: Container(),
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  fabPosition = offset;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // 新的选中项
        currentIndex: _currentIndex, // 当前选中的项
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.calendar_today),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: '待办事项',
          ),
        ],
      ),
    );
  }
}
