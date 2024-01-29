import 'package:flutter/material.dart';
import '../widgets/mission2.dart';
import '../widgets/toDoList2.dart';
import '../widgets/manager.dart'; // 引入PersonaDrawer
import '../widgets/Calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home2Page extends StatefulWidget {
  final String managerEmail;

  Home2Page({Key? key, required this.managerEmail}) : super(key: key); // 构造函数

  @override
  _Home2PageState createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Offset fabPosition = Offset(20.0, 20.0); // 浮动按钮的初始位置
  int _currentIndex = 0; // 当前选中的页面索引
  final List<Widget> _children = [
    Mission2Page(),
    CalendarPage(),
    ToDoList2Page(),
    //PersonaPage(), // 假设有个人资料/设置界面
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
      drawer:
          ManagerDrawer(managerEmail: widget.managerEmail), // 使用PersonaDrawer
      body: Stack(
        children: [
          _children[_currentIndex], // 当前选中的页面
          Positioned(
            left: fabPosition.dx,
            top: fabPosition.dy,
            child: Draggable(
              child: FloatingActionButton(
                heroTag: "Manager",
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                child: Icon(Icons.menu),
              ),
              feedback: FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.menu),
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
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '任务管理',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.calendar_today),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '待办事项',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: '个人资料',
          // ),
        ],
      ),
    );
  }
}
