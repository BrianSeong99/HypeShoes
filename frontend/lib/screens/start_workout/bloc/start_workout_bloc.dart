import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:fitness_flutter/screens/start_workout/data/live_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;

part 'start_workout_event.dart';
part 'start_workout_state.dart';

class StartWorkoutBloc extends Bloc<StartWorkoutEvent, StartWorkoutState> {
  StartWorkoutBloc() : super(StartWorkoutInitial());

  int time = 19;
  late List<LiveData> chartData;
  late ChartSeriesController chartSeriesController;

  void updateDataSource() {
    chartData.add(LiveData(time: time++, value: (math.Random().nextInt(60) + 30)));
    chartData.removeAt(0);
    chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }

  @override
  Stream<StartWorkoutState> mapEventToState(
    StartWorkoutEvent event,
  ) async* {
    if (event is BackTappedEvent) {
      yield BackTappedState();
    } else if (event is PlayTappedEvent) {
      time = event.time;
      yield PlayTimerState(time: event.time);
    } else if (event is PauseTappedEvent) {
      time = event.time;
      yield PauseTimerState(currentTime: time);
    } else if (event is DuringTimerEvent) {
      time = event.time;
      updateDataSource();
      yield DuringTimerState(time: time);
    }
  }
}
