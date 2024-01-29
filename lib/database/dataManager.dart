import "package:cloud_firestore/cloud_firestore.dart";

class Task {
  String id; // 唯一标识符
  String title;
  String description;
  int progress; // 进度，整数类型
  String issues;
  String estimatedCompletionDate; // 预计完成日期
  String responsible; // 负责人

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.issues,
    required this.estimatedCompletionDate,
    required this.responsible,
  });

  // 从Firestore文档创建Task对象
  factory Task.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return Task(
      id: firestoreDoc['id'] as String,
      title: firestoreDoc['title'] as String,
      description: firestoreDoc['description'] as String,
      progress: firestoreDoc['progress'] as int,
      issues: firestoreDoc['issues'] as String,
      estimatedCompletionDate:
          firestoreDoc['estimatedCompletionDate'] as String,
      responsible: firestoreDoc['responsible'] as String,
    );
  }

  // 将Task对象转换为Map，以便存储到Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'issues': issues,
      'estimatedCompletionDate': estimatedCompletionDate,
      'responsible': responsible,
    };
  }
}

class Mission {
  String id; // 用于唯一标识任务
  String title; // 任务标题
  String description; // 任务描述
  List<String> challenges; // 可能面临的难题，作为列表

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.challenges,
  });

  // 从Firestore文档创建Mission对象
  factory Mission.fromFirestore(Map<String, dynamic> firestoreDoc) {
    List<String> challengesList =
        (firestoreDoc['challenges'] as String).split('\n');
    return Mission(
      id: firestoreDoc['id'] as String,
      title: firestoreDoc['title'] as String,
      description: firestoreDoc['description'] as String,
      challenges: challengesList,
    );
  }

  // 将Mission对象转换为Map，以便存储到Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'challenges': challenges.join('\n'), // 将列表转换为字符串
    };
  }
}

class CalendarEvent {
  String id;
  DateTime date;
  String title; // 任务标题
  String responsible; // 负责人名称

  CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.responsible,
  });

  // 从Firestore文档创建CalendarEvent对象
  factory CalendarEvent.fromFirestore(
      Map<String, dynamic> firestoreDoc, String docId) {
    return CalendarEvent(
      id: docId,
      date: (firestoreDoc['date'] as Timestamp).toDate(),
      title: firestoreDoc['title'] as String,
      responsible: firestoreDoc['responsible'] as String,
    );
  }

  // 将CalendarEvent对象转换为Map，以便存储到Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'title': title,
      'responsible': responsible,
    };
  }
}

class Employee {
  String id; // 用户的唯一标识符
  String name; // 名字
  String position; // 职位
  String department; // 部门

  Employee(
      {required this.id,
      required this.name,
      required this.position,
      required this.department});

  // 从Firestore文档创建Employee对象
  factory Employee.fromFirestore(Map<String, dynamic> firestoreDoc, String id) {
    return Employee(
      id: id,
      name: firestoreDoc['name'] as String,
      position: firestoreDoc['position'] as String,
      department: firestoreDoc['department'] as String,
    );
  }

  // 将Employee对象转换为Map，以便存储到Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'position': position,
      'department': department,
    };
  }
}

class Manager {
  final String email;
  final String hashedPassword;
  final String position;
  final String department;

  Manager({
    required this.email,
    required this.hashedPassword,
    required this.position,
    required this.department,
  });

  // 从 Firestore 文档创建 Manager 对象
  factory Manager.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return Manager(
      email: firestoreDoc['email'] as String,
      hashedPassword: firestoreDoc['hashedPassword'] as String,
      position: firestoreDoc['position'] as String,
      department: firestoreDoc['department'] as String,
    );
  }

  // 将 Manager 对象转换为 Map，以便存储到 Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'hashedPassword': hashedPassword,
      'position': position,
      'department': department,
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Manager
  // 创建管理员
  Future<void> createManager(Manager manager) async {
    await _firestore
        .collection('managers')
        .doc(manager.email)
        .set(manager.toFirestore());
  }

// 监听与给定电子邮件匹配的管理员的变化
  Stream<Manager?> getManagerStream(String email) {
    return _firestore
        .collection('managers')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Manager.fromFirestore(snapshot.docs.first.data());
      }
      return null;
    });
  }

// 查找与给定电子邮件匹配的管理员
  Future<Manager?> getManager(String email) async {
    // 查询managers集合中电子邮件字段匹配的文档
    var querySnapshot = await _firestore
        .collection('managers')
        .where('email', isEqualTo: email)
        .get();

    // 如果找到匹配的文档，返回Manager对象
    if (querySnapshot.docs.isNotEmpty) {
      return Manager.fromFirestore(querySnapshot.docs.first.data());
    }
    return null;
  }

// 更新管理员
  Future<void> updateManager(Manager manager, String email) async {
    var querySnapshot = await _firestore
        .collection('managers')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 获取匹配的第一个文档的ID
      String docId = querySnapshot.docs.first.id;

      // 使用文档ID来更新数据
      await _firestore
          .collection('managers')
          .doc(docId)
          .update(manager.toFirestore());
    }
  }

  // 删除管理员
  Future<void> deleteManager(String email) async {
    await _firestore.collection('managers').doc(email).delete();
  }

  // 创建或更新任务
  Future<void> setTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toFirestore());
  }

  // 读取单个任务
  Future<Task?> getTask(String taskId) async {
    var snapshot = await _firestore.collection('tasks').doc(taskId).get();
    if (snapshot.exists) {
      return Task.fromFirestore(snapshot.data()!);
    }
    return null;
  }

  // 获取任务的Stream
  Stream<List<Task>> getTasksStream() {
    return _firestore.collection('tasks').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc.data())).toList());
  }

  // 获取所有任务
  Future<List<Task>> getAllTasks() async {
    QuerySnapshot snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc.data()! as Map<String, dynamic>))
        .toList();
  }

  // 删除任务
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // 更新任务
  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id)
        .update(task.toFirestore());
  }

  // 创建或更新任务目标
  Future<void> setMission(Mission mission) async {
    await _firestore
        .collection('missions')
        .doc(mission.id)
        .set(mission.toFirestore());
  }

  // 读取单个Mission
  Future<Mission?> getMission(String missionId) async {
    var snapshot = await _firestore.collection('missions').doc(missionId).get();
    if (snapshot.exists) {
      return Mission.fromFirestore(snapshot.data()!);
    }
    return null;
  }

// 获取全部Missions的实时流
  Stream<List<Mission>> getMissionsStream() {
    return _firestore.collection('missions').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Mission.fromFirestore(doc.data()!))
          .toList();
    });
  }

  // 删除Mission
  Future<void> deleteMission(String missionId) async {
    await _firestore.collection('missions').doc(missionId).delete();
  }

  // 创建或更新日历事件
  Future<void> setCalendarEvent(CalendarEvent event, String id) async {
    await _firestore
        .collection('calendarEvents')
        .doc(id)
        .set(event.toFirestore());
  }

  // 获取所有日历事件
  Future<List<CalendarEvent>> getAllCalendarEvents() async {
    var snapshot = await _firestore.collection('calendarEvents').get();
    return snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc.data()!, doc.id))
        .toList();
  }

  // 读取单个日历事件
  Future<CalendarEvent?> getCalendarEvent(DateTime eventDate, String id) async {
    var snapshot = await _firestore
        .collection('calendarEvents')
        .doc(eventDate.toIso8601String())
        .get();
    if (snapshot.exists) {
      return CalendarEvent.fromFirestore(snapshot.data()!, id);
    }
    return null;
  }

  // 删除日历事件
  Future<void> deleteCalendarEvent(String id) async {
    await _firestore.collection('calendarEvents').doc(id).delete();
  }

  // 更新日历事件
  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await _firestore
        .collection('calendarEvents')
        .doc(event.id)
        .update(event.toFirestore());
  }

  // 获取所有CalendarEvent的Stream
  Stream<List<CalendarEvent>> getCalendarEventsStream() {
    return _firestore.collection('calendarEvents').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => CalendarEvent.fromFirestore(doc.data()!, doc.id))
            .toList());
  }

  // 创建或更新用户
  Future<void> setEmployee(Employee Employee) async {
    await _firestore
        .collection('Employees')
        .doc(Employee.id)
        .set(Employee.toFirestore());
  }

// 监听单个用户的变化
  Stream<Employee?> getEmployeeStream(String employeeId) {
    return _firestore
        .collection('Employees')
        .doc(employeeId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Employee.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // 获取单个员工的详细信息
  Future<Employee?> getEmployee(String employeeId) async {
    var snapshot =
        await _firestore.collection('Employees').doc(employeeId).get();
    if (snapshot.exists) {
      return Employee.fromFirestore(snapshot.data()!, snapshot.id);
    }
    return null;
  }

  // 更新用户
  Future<void> updateEmployee(Employee Employee) async {
    await _firestore
        .collection('Employees')
        .doc(Employee.id)
        .update(Employee.toFirestore());
  }

  // 删除用户
  Future<void> deleteEmployee(String EmployeeId) async {
    await _firestore.collection('Employees').doc(EmployeeId).delete();
  }

  // 获取用户的Stream（用于实时更新）
  Stream<List<Employee>> getEmployeesStream() {
    return _firestore.collection('Employees').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Employee.fromFirestore(doc.data()!, doc.id))
            .toList());
  }
}
