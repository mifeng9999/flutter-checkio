import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timefly/add_habit/edit_name.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/record_bloc.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/utils/date_util.dart';
import 'package:timefly/utils/habit_util.dart';
import 'package:timefly/utils/pair.dart';
import 'package:timeline_tile/timeline_tile.dart';

class HabitCheckView extends StatefulWidget {
  final DateTime start;
  final DateTime end;

  final String habitId;

  const HabitCheckView({Key key, this.habitId, this.start, this.end})
      : super(key: key);

  @override
  _HabitCheckViewState createState() => _HabitCheckViewState();
}

class _HabitCheckViewState extends State<HabitCheckView> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final SlidableController slidableController = SlidableController();
  final ScrollController scrollController = ScrollController();

  List<HabitRecord> habitRecords = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordBloc(BlocProvider.of<HabitsBloc>(context))
        ..add(RecordLoad(widget.habitId, widget.start, widget.end)),
      child: BlocBuilder<RecordBloc, RecordState>(
        builder: (context, state) {
          if (state is RecordLoadSuccess) {
            habitRecords = HabitUtil.filterHabitRecordsWithTime(state.records,
                start: widget.start, end: widget.end);
            return Scaffold(
              backgroundColor: AppTheme.appTheme.containerBackgroundColor(),
              body: Stack(
                children: [
                  Container(
                    child: AnimatedList(
                      key: listKey,
                      padding: EdgeInsets.only(top: 50, bottom: 16),
                      controller: scrollController,
                      initialItemCount: habitRecords.length,
                      itemBuilder: (context, index, animation) {
                        return getCheckItemView(
                            context, habitRecords[index], animation);
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 16, top: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(
                        'assets/images/guanbi.svg',
                        color: Colors.black,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  HabitRecord record = HabitRecord(
                      habitId: widget.habitId,
                      time: DateTime.now().millisecondsSinceEpoch,
                      content: '');

                  BlocProvider.of<RecordBloc>(context).add(RecordAdd(record));
                  listKey.currentState.insertItem(0,
                      duration: const Duration(milliseconds: 500));
                  scrollController.animateTo(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                },
                backgroundColor: Colors.blueAccent,
                child: SvgPicture.asset(
                  'assets/images/jia.svg',
                  color: Colors.white,
                  width: 40,
                  height: 40,
                ),
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget getCheckItemView(
      BuildContext context, HabitRecord record, Animation<dynamic> animation) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      child: TimelineTile(
        beforeLineStyle: LineStyle(thickness: 2, color: Colors.black26),
        indicatorStyle: IndicatorStyle(
          width: 35,
          color: AppTheme.appTheme.containerBackgroundColor(),
          indicatorXY: 0.5,
          iconStyle: IconStyle(
            color: Colors.black,
            iconData: Icons.check_circle_outline,
          ),
        ),
        alignment: TimelineAlign.manual,
        lineXY: 0.1,
        isFirst: habitRecords.indexOf(record) == 0,
        isLast: habitRecords.indexOf(record) == habitRecords.length - 1,
        endChild: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset(0, 0),
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 20, left: 28),
            child: Slidable(
              key: GlobalKey(),
              controller: slidableController,
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: [
                GestureDetector(
                  onTap: () async {
                    removeItem(context, record);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.redAccent.withOpacity(0.35),
                                offset: const Offset(2, 2.0),
                                blurRadius: 6.0),
                          ],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.red),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )
              ],
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(5.1, 6.0),
                            blurRadius: 14.0),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          '${DateUtil.parseHourAndMinAndSecond(record.time)}',
                          style: AppTheme.appTheme
                              .textStyle(
                                  textColor: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)
                              .copyWith(fontFamily: 'Montserrat'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 24),
                        child: Text(
                          '${DateUtil.parseYearAndMonthAndDay(record.time)}',
                          style: AppTheme.appTheme
                              .textStyle(
                                  textColor: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)
                              .copyWith(fontFamily: 'Montserrat'),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          editNote(context, record);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(
                              left: 16, right: 16, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color:
                                  AppTheme.appTheme.containerBackgroundColor()),
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 60),
                          child: Text(
                            '${record.content.length == 0 ? '记录些什么...' : record.content}',
                            style: AppTheme.appTheme.textStyle(
                                textColor: record.content.length == 0
                                    ? Colors.black54
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  void removeItem(BuildContext context, HabitRecord record) async {
    BlocProvider.of<RecordBloc>(context)
        .add(RecordDelete(widget.habitId, record.time));

    int index = habitRecords.indexOf(record);
    listKey.currentState.removeItem(
        index, (_, animation) => getCheckItemView(_, record, animation),
        duration: const Duration(milliseconds: 500));
  }

  void editNote(BuildContext context, HabitRecord record) async {
    Mutable<String> content = Mutable(record.content);
    await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, ani1, ani2) {
          return EditFiledView(
            content: content,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Animation<double> myAnimation = Tween<double>(begin: 0, end: 1.0)
              .animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutSine,
                  reverseCurve: Interval(0, 0.5, curve: Curves.easeInSine)));
          return Transform(
            transform:
                Matrix4.translationValues(0, 100 * (1 - myAnimation.value), 0),
            child: FadeTransition(
              opacity: myAnimation,
              child: child,
            ),
          );
        }));
    BlocProvider.of<RecordBloc>(context).add(RecordUpdate(record.copyWith(
        habitId: record.habitId, time: record.time, content: content.value)));
  }
}