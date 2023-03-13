import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:fitness_flutter/screens/start_workout/data/live_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';


part 'start_workout_event.dart';
part 'start_workout_state.dart';

class StartWorkoutBloc extends Bloc<StartWorkoutEvent, StartWorkoutState> {
  StartWorkoutBloc() : super(StartWorkoutInitial());

  int time = 19;
  late List<LiveData> leftSensor0;
  late List<LiveData> leftSensor1;
  late List<LiveData> leftSensor2;
  late List<LiveData> leftSensor3;

  late List<LiveData> leftAccel0;
  late List<LiveData> leftAccel1;
  late List<LiveData> leftAccel2;
  late List<LiveData> leftGyro0;
  late List<LiveData> leftGyro1;
  late List<LiveData> leftGyro2;

  late ChartSeriesController chartSeriesControllerLeftPressure0;
  late ChartSeriesController chartSeriesControllerLeftPressure1;
  late ChartSeriesController chartSeriesControllerLeftPressure2;
  late ChartSeriesController chartSeriesControllerLeftPressure3;
  late ChartSeriesController chartSeriesControllerLeftAccel0;
  late ChartSeriesController chartSeriesControllerLeftAccel1;
  late ChartSeriesController chartSeriesControllerLeftAccel2;
  late ChartSeriesController chartSeriesControllerLeftGyro0;
  late ChartSeriesController chartSeriesControllerLeftGyro1;
  late ChartSeriesController chartSeriesControllerLeftGyro2;

  late List<LiveData> rightSensor0;
  late List<LiveData> rightSensor1;
  late List<LiveData> rightSensor2;
  late List<LiveData> rightSensor3;

  late List<LiveData> rightAccel0;
  late List<LiveData> rightAccel1;
  late List<LiveData> rightAccel2;
  late List<LiveData> rightGyro0;
  late List<LiveData> rightGyro1;
  late List<LiveData> rightGyro2;

  late ChartSeriesController chartSeriesControllerRightPressure0;
  late ChartSeriesController chartSeriesControllerRightPressure1;
  late ChartSeriesController chartSeriesControllerRightPressure2;
  late ChartSeriesController chartSeriesControllerRightPressure3;
  late ChartSeriesController chartSeriesControllerRightAccel0;
  late ChartSeriesController chartSeriesControllerRightAccel1;
  late ChartSeriesController chartSeriesControllerRightAccel2;
  late ChartSeriesController chartSeriesControllerRightGyro0;
  late ChartSeriesController chartSeriesControllerRightGyro1;
  late ChartSeriesController chartSeriesControllerRightGyro2;



  late Timer? timer;

  int frequency = 500;

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void updateDataSource() async {
    
    time = time + 1;

    var request = http.Request('GET', Uri.parse('http://127.0.0.1:5001/user/data/record'));


    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final body = json.decode(responseBody);

      if (body['left_sequence_data'].length > 1) {
        final leftData = body['left_sequence_data'][body['left_sequence_data'].length-1];

        leftSensor0.add(LiveData(time: time, value: num.parse(leftData[0])));
        leftSensor1.add(LiveData(time: time, value: num.parse(leftData[1])));
        leftSensor2.add(LiveData(time: time, value: num.parse(leftData[2])));
        leftSensor3.add(LiveData(time: time, value: num.parse(leftData[3])));
        leftAccel0.add(LiveData(time: time, value: num.parse(leftData[5])));
        leftAccel1.add(LiveData(time: time, value: num.parse(leftData[6])));
        leftAccel2.add(LiveData(time: time, value: num.parse(leftData[7])));
        leftGyro0.add(LiveData(time: time, value: num.parse(leftData[8])));
        leftGyro1.add(LiveData(time: time, value: num.parse(leftData[9])));
        leftGyro2.add(LiveData(time: time, value: num.parse(leftData[10])));
        
        leftSensor0.removeAt(0);
        leftSensor1.removeAt(0);
        leftSensor2.removeAt(0);
        leftSensor3.removeAt(0);
        leftAccel0.removeAt(0);
        leftAccel1.removeAt(0);
        leftAccel2.removeAt(0);
        leftGyro0.removeAt(0);
        leftGyro1.removeAt(0);
        leftGyro2.removeAt(0);
        
        chartSeriesControllerLeftPressure0.updateDataSource(addedDataIndex: leftSensor0.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftPressure1.updateDataSource(addedDataIndex: leftSensor1.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftPressure2.updateDataSource(addedDataIndex: leftSensor2.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftPressure3.updateDataSource(addedDataIndex: leftSensor3.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftAccel0.updateDataSource(addedDataIndex: leftAccel0.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftAccel1.updateDataSource(addedDataIndex: leftAccel1.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftAccel2.updateDataSource(addedDataIndex: leftAccel2.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftGyro0.updateDataSource(addedDataIndex: leftGyro0.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftGyro1.updateDataSource(addedDataIndex: leftGyro1.length - 1, removedDataIndex: 0);
        chartSeriesControllerLeftGyro2.updateDataSource(addedDataIndex: leftGyro2.length - 1, removedDataIndex: 0);
      }

      if (body['right_sequence_data'].length > 1) {
        final rightData = body['right_sequence_data'][body['right_sequence_data'].length-1];
        rightSensor0.add(LiveData(time: time, value: num.parse(rightData[0])));
        rightSensor1.add(LiveData(time: time, value: num.parse(rightData[1])));
        rightSensor2.add(LiveData(time: time, value: num.parse(rightData[2])));
        rightSensor3.add(LiveData(time: time, value: num.parse(rightData[3])));
        rightAccel0.add(LiveData(time: time, value: num.parse(rightData[5])));
        rightAccel1.add(LiveData(time: time, value: num.parse(rightData[6])));
        rightAccel2.add(LiveData(time: time, value: num.parse(rightData[7])));
        rightGyro0.add(LiveData(time: time, value: num.parse(rightData[8])));
        rightGyro1.add(LiveData(time: time, value: num.parse(rightData[9])));
        rightGyro2.add(LiveData(time: time, value: num.parse(rightData[10])));
        
        rightSensor0.removeAt(0);
        rightSensor1.removeAt(0);
        rightSensor2.removeAt(0);
        rightSensor3.removeAt(0);
        rightAccel0.removeAt(0);
        rightAccel1.removeAt(0);
        rightAccel2.removeAt(0);
        rightGyro0.removeAt(0);
        rightGyro1.removeAt(0);
        rightGyro2.removeAt(0);
        
        chartSeriesControllerRightPressure0.updateDataSource(addedDataIndex: rightSensor0.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightPressure1.updateDataSource(addedDataIndex: rightSensor1.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightPressure2.updateDataSource(addedDataIndex: rightSensor2.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightPressure3.updateDataSource(addedDataIndex: rightSensor3.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightAccel0.updateDataSource(addedDataIndex: rightAccel0.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightAccel1.updateDataSource(addedDataIndex: rightAccel1.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightAccel2.updateDataSource(addedDataIndex: rightAccel2.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightGyro0.updateDataSource(addedDataIndex: rightGyro0.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightGyro1.updateDataSource(addedDataIndex: rightGyro1.length - 1, removedDataIndex: 0);
        chartSeriesControllerRightGyro2.updateDataSource(addedDataIndex: rightGyro2.length - 1, removedDataIndex: 0);
      }
    } else if(response.statusCode == 201) {
      String responseBody = await response.stream.bytesToString();
    }
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
