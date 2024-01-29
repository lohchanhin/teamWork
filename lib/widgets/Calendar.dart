import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/dataManager.dart';

// 定义事件类
class Event {
  final String title;
  final String responsible;
  const Event(this.title, this.responsible);
  @override
  String toString() => '$title (负责人: $responsible)';
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late final ValueNotifier<List<Event>> _selectedEvents;
  Map<DateTime, List<Event>> _allEvents = {}; // 存储所有事件的映射
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _fetchAndSyncAllEvents(); // 在初始化时获取和同步所有事件
  }

  Future<void> _fetchAndSyncAllEvents() async {
    var firestoreEvents = await _firestoreService.getAllCalendarEvents();
    _allEvents.clear();
    for (var event in firestoreEvents) {
      final dayKey =
          DateTime.utc(event.date.year, event.date.month, event.date.day);
      _allEvents
          .putIfAbsent(dayKey, () => [])
          .add(Event(event.title, event.responsible));
    }
    setState(() {
      _selectedEvents.value = _allEvents[_selectedDay] ?? []; // 更新选中日期的事件
    });
  }

  // 根据选中的日期获取事件
  void _fetchEventsForSelectedDay() {
    List<Event> events = _allEvents[_selectedDay] ?? [];
    _selectedEvents.value = events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('日历'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchEventsForSelectedDay();
            },
            eventLoader: (day) {
              return _allEvents[day] ?? []; // 使用 _allEvents 获取特定日期的事件
            },
            calendarStyle: CalendarStyle(
              // Customizing the calendar style
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            // 其他配置...
          ),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        value[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // 加粗字体
                          color: Colors.blue, // 标题蓝色
                        ),
                      ),
                      trailing: Text(
                        '负责人: ${value[index].responsible}',
                        style: TextStyle(
                          fontStyle: FontStyle.normal, // 斜体字
                          color: Colors.black, // 灰色字体
                          fontSize: 15,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16), // 内边距
                      onTap: () {
                        // 点击事件处理
                        print('点击了 ${value[index].title}');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
