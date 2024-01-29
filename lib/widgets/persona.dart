import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/dataManager.dart';

class PersonaDrawer extends StatelessWidget {
  PersonaDrawer({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 更新用户资料的方法
  void _updateProfile(BuildContext context, Employee? currentUserInfo) {
    // 创建控制器和初始值
    final TextEditingController _nameController =
        TextEditingController(text: currentUserInfo?.name);
    final TextEditingController _positionController =
        TextEditingController(text: currentUserInfo?.position);
    final TextEditingController _departmentController =
        TextEditingController(text: currentUserInfo?.department);

    // 显示对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('编辑个人资料'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: '名字')),
                TextField(
                    controller: _positionController,
                    decoration: InputDecoration(labelText: '职位')),
                TextField(
                    controller: _departmentController,
                    decoration: InputDecoration(labelText: '部门')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('取消'), onPressed: () => Navigator.pop(context)),
            TextButton(
              child: Text('确认'),
              onPressed: () {
                // 更新Firebase中的用户信息
                FirestoreService().updateEmployee(Employee(
                  id: _auth.currentUser!.uid, // 获取当前用户ID
                  name: _nameController.text,
                  position: _positionController.text,
                  department: _departmentController.text,
                ));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 用户登出方法
  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // 返回登录页面
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16, // 添加阴影效果
      child: StreamBuilder<Employee?>(
        stream: FirestoreService().getEmployeeStream(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            Employee? currentUserInfo = snapshot.data;
            return _buildDrawerContent(context, currentUserInfo);
          }
          return CircularProgressIndicator(); // 显示加载中
        },
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context, Employee? currentUserInfo) {
    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(currentUserInfo?.name ?? '用户名'),
          accountEmail: Text(
              '${currentUserInfo?.position ?? ''} - ${currentUserInfo?.department ?? ''}'),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(
              currentUserInfo?.name.substring(0, 1).toUpperCase() ?? "A",
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('个人资料设置'),
                onTap: () => _updateProfile(context, currentUserInfo),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('登出'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
