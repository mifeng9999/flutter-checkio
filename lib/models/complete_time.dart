class CompleteTime {
  ///-1 全部
  ///0 任意
  ///1 早上
  ///2 上午
  ///3 中午
  ///4 下午
  ///5 晚上
  final int time;
  bool isSelect = false;

  CompleteTime(this.time, {this.isSelect = false});

  static List<CompleteTime> getCompleteTimes() {
    List<CompleteTime> completeTimes = [];
    for (int i = 0; i <= 5; i++) {
      completeTimes.add(CompleteTime(i, isSelect: i == 0));
    }
    return completeTimes;
  }

  static String getTime(int time) {
    String timeString = '任意';
    switch (time) {
      case -1:
        timeString = '全部';
        break;
      case 1:
        timeString = '早上';
        break;
      case 2:
        timeString = '上午';
        break;
      case 3:
        timeString = '中午';
        break;
      case 4:
        timeString = '下午';
        break;
      case 5:
        timeString = '晚上';
        break;
    }
    return timeString;
  }
}

class CompleteDay {
  final int day;
  bool isSelect = false;

  CompleteDay(this.day, {this.isSelect = false});

  static List<CompleteDay> getCompleteDays() {
    List<CompleteDay> days = [];
    for (int i = 1; i <= 7; i++) {
      days.add(CompleteDay(i, isSelect: true));
    }

    return days;
  }

  static String getDay(int day) {
    String dayString = '';
    switch (day) {
      case 1:
        dayString = '周一';
        break;
      case 2:
        dayString = '周二';
        break;
      case 3:
        dayString = '周三';
        break;
      case 4:
        dayString = '周四';
        break;
      case 5:
        dayString = '周五';
        break;
      case 6:
        dayString = '周六';
        break;
      case 7:
        dayString = '周日';
        break;
    }
    return dayString;
  }
}