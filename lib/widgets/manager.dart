import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/dataManager.dart';

class ManagerDrawer extends StatelessWidget {
  final String managerEmail; // 管理员邮箱

  ManagerDrawer({Key? key, required this.managerEmail}) : super(key: key);

  void _updateProfile(BuildContext context, Manager? currentManager) {
    final TextEditingController _emailController =
        TextEditingController(text: currentManager?.email);
    final TextEditingController _positionController =
        TextEditingController(text: currentManager?.position);
    final TextEditingController _departmentController =
        TextEditingController(text: currentManager?.department);
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();
    bool _obscurePassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('编辑管理员资料'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: '邮箱')),
                    TextField(
                        controller: _positionController,
                        decoration: InputDecoration(labelText: '职位')),
                    TextField(
                        controller: _departmentController,
                        decoration: InputDecoration(labelText: '部门')),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: '新密码',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: '确认新密码'),
                      obscureText: _obscurePassword,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text('取消'), onPressed: () => Navigator.pop(context)),
                TextButton(
                  child: Text('确认'),
                  onPressed: () {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      // 更新Firebase中的管理员信息，包括新密码
                      FirestoreService().updateManager(
                          Manager(
                            email: _emailController.text,
                            hashedPassword: _passwordController.text,
                            position: _positionController.text,
                            department: _departmentController.text,
                          ),
                          managerEmail);
                      Navigator.pop(context);
                    } else {
                      // 密码不匹配的处理逻辑
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('密码不匹配，请重新输入')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // 不需要设置 managerEmail = ''; 因为它是 final 类型的
    Navigator.of(context).pushReplacementNamed('/login'); // 登出并跳转到登录页面
  }

  @override
  Widget build(BuildContext context) {
    if (managerEmail.isEmpty) {
      // 如果没有管理员邮箱，显示相应的信息
      return Drawer(
        child: Center(child: Text('无有效管理员邮箱')),
      );
    }

// 如果有管理员邮箱，根据邮箱构建抽屉内容
    return Drawer(
      elevation: 16,
      child: StreamBuilder<Manager?>(
        stream: FirestoreService().getManagerStream(managerEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            Manager? currentManager = snapshot.data;
            print(currentManager);
            return _buildDrawerContent(context, currentManager);
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildDrawerContent(BuildContext context, Manager? currentManager) {
    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(currentManager?.email ?? '管理员邮箱'),
          accountEmail: Text(
              '${currentManager?.position ?? ''} - ${currentManager?.department ?? ''}'),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(
              currentManager?.email.substring(0, 1).toUpperCase() ?? "M",
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('管理员资料设置'),
                onTap: () => _updateProfile(context, currentManager),
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
