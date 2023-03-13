import 'package:fitness_flutter/core/const/color_constants.dart';
import 'package:fitness_flutter/core/const/path_constants.dart';
import 'package:fitness_flutter/core/const/text_constants.dart';
import 'package:fitness_flutter/data/exercise_data.dart';
import 'package:fitness_flutter/screens/common_widgets/fitness_button.dart';
import 'package:fitness_flutter/screens/start_workout/bloc/start_workout_bloc.dart';
import 'package:fitness_flutter/screens/start_workout/page/start_workout_page.dart';
import 'package:fitness_flutter/screens/start_workout/widget/start_workout_video.dart';
import 'package:fitness_flutter/screens/workout_details_screen/bloc/workoutdetails_bloc.dart' as workout_bloc;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'package:fitness_flutter/screens/start_workout/data/live_data.dart';
import 'package:http/http.dart' as http;


class StartWorkoutContent extends StatelessWidget {
  final ExerciseData exercise;
  final ExerciseData? nextExercise;

  StartWorkoutContent({required this.exercise, required this.nextExercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: ColorConstants.white,
      child: SafeArea(
        child: _createDetailedExercise(context),
      ),
    );
  }

  Widget _createDetailedExercise(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createBackButton(context),
          const SizedBox(height: 23),
          // _createVideo(context),
          // const SizedBox(height: 8),
          Expanded(
            child: ListView(children: [
              _createTitle(),
              const SizedBox(height: 9),
              _createDescription(),
              const SizedBox(height: 30),
              // _createSteps(),
              _createSubTitle("Left", "Pressure"),
              const SizedBox(height: 3),
              _createChart("Left", "Pressure", context),
              const SizedBox(height: 9),

              _createSubTitle("Right", "Pressure"),
              const SizedBox(height: 3),
              _createChart("Right", "Pressure", context),
              const SizedBox(height: 9),

              _createSubTitle("Left", "IMU"),
              const SizedBox(height: 3),
              _createChart("Left", "IMU", context),
              const SizedBox(height: 9),

              _createSubTitle("Right", "IMU"),
              const SizedBox(height: 3),
              _createChart("Right", "IMU", context),
              const SizedBox(height: 9),
            ]),
          ),
          _createTimeTracker(context),
        ],
      ),
    );
  }

  Widget _createChart(String leftOrRight, String pressureOrIMU, BuildContext context) {
    final bloc = BlocProvider.of<StartWorkoutBloc>(context);
    if (leftOrRight == "Left" && pressureOrIMU == "Pressure") {
      return SfCartesianChart(
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftPressure0 = controller;
            },
            dataSource: bloc.leftSensor0,
            color: Color.fromARGB(255, 156, 19, 58),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftPressure1 = controller;
            },
            dataSource: bloc.leftSensor1,
            color: Color.fromARGB(255, 75, 150, 5),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftPressure2 = controller;
            },
            dataSource: bloc.leftSensor2,
            color: Color.fromARGB(255, 11, 207, 207),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftPressure3 = controller;
            },
            dataSource: bloc.leftSensor3,
            color: Color.fromARGB(255, 154, 154, 3),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          )
        ],
        primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 3,
          title: AxisTitle(text: 'Time (seconds)')
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          // title: AxisTitle(text: '')
        )
      );
    } else if (leftOrRight == "Right" && pressureOrIMU == "Pressure") {
      return SfCartesianChart(
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightPressure0 = controller;
            },
            dataSource: bloc.rightSensor0,
            color: Color.fromARGB(255, 156, 19, 58),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightPressure1 = controller;
            },
            dataSource: bloc.rightSensor1,
            color: Color.fromARGB(255, 75, 150, 5),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightPressure2 = controller;
            },
            dataSource: bloc.rightSensor2,
            color: Color.fromARGB(255, 11, 207, 207),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightPressure3 = controller;
            },
            dataSource: bloc.rightSensor3,
            color: Color.fromARGB(255, 154, 154, 3),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          )
        ],
        primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 3,
          title: AxisTitle(text: 'Time (seconds)')
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          // title: AxisTitle(text: '')
        )
      );
    } else if (leftOrRight == "Left" && pressureOrIMU == "IMU") {
      return SfCartesianChart(
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftAccel0 = controller;
            },
            dataSource: bloc.leftAccel0,
            color: Color.fromARGB(255, 156, 19, 58),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftAccel1 = controller;
            },
            dataSource: bloc.leftAccel1,
            color: Color.fromARGB(255, 75, 150, 5),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftAccel2 = controller;
            },
            dataSource: bloc.leftAccel2,
            color: Color.fromARGB(255, 11, 207, 207),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftGyro0 = controller;
            },
            dataSource: bloc.leftGyro0,
            color: Color.fromARGB(255, 154, 154, 3),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftGyro1 = controller;
            },
            dataSource: bloc.leftGyro1,
            color: Color.fromARGB(255, 78, 19, 156),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerLeftGyro2 = controller;
            },
            dataSource: bloc.leftGyro2,
            color: Color.fromARGB(255, 45, 27, 7),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
        ],
        primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 3,
          title: AxisTitle(text: 'Time (seconds)')
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          // title: AxisTitle(text: '')
        )
      );
    }
    return SfCartesianChart(
        series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightAccel0 = controller;
            },
            dataSource: bloc.rightAccel0,
            color: Color.fromARGB(255, 156, 19, 58),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightAccel1 = controller;
            },
            dataSource: bloc.rightAccel1,
            color: Color.fromARGB(255, 75, 150, 5),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightAccel2 = controller;
            },
            dataSource: bloc.rightAccel2,
            color: Color.fromARGB(255, 11, 207, 207),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightGyro0 = controller;
            },
            dataSource: bloc.rightGyro0,
            color: Color.fromARGB(255, 154, 154, 3),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightGyro1 = controller;
            },
            dataSource: bloc.rightGyro1,
            color: Color.fromARGB(255, 78, 19, 156),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
          LineSeries<LiveData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              bloc.chartSeriesControllerRightGyro2 = controller;
            },
            dataSource: bloc.rightGyro2,
            color: Color.fromARGB(255, 45, 27, 7),
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.value,
          ),
        ],
        primaryXAxis: NumericAxis(
          majorGridLines: const MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 3,
          title: AxisTitle(text: 'Time (seconds)')
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          // title: AxisTitle(text: '')
        )
      );
  }

  Widget _createBackButton(BuildContext context) {
    final bloc = BlocProvider.of<StartWorkoutBloc>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8),
      child: GestureDetector(
        child: BlocBuilder<StartWorkoutBloc, StartWorkoutState>(
          builder: (context, state) {
            return Row(
              children: [
                Image(image: AssetImage(PathConstants.back)),
                const SizedBox(width: 17),
                Text(
                  TextConstants.back,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
        onTap: () {
          bloc.add(BackTappedEvent());
        },
      ),
    );
  }

  Widget _createVideo(BuildContext context) {
    final bloc = BlocProvider.of<StartWorkoutBloc>(context);
    return Container(
      height: 264,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: ColorConstants.white),
      child: StartWorkoutVideo(
        exercise: exercise,
        onPlayTapped: (time) {
          bloc.add(PlayTappedEvent(time: time));
        },
        onPauseTapped: (time) {
          bloc.add(PauseTappedEvent(time: time));
        },
      ),
    );
  }

  Widget _createTitle() {
    return Text(exercise.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
  }

  Widget _createSubTitle(String leftOrRight, String pressureOrIMU) {
    return Text(leftOrRight + " " + pressureOrIMU, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _createDescription() {
    return Text(exercise.description, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
  }

  Widget _createSteps() {
    return Column(
      children: [
        for (int i = 0; i < exercise.steps.length; i++) ...[
          Step(number: "${i + 1}", description: exercise.steps[i]),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _createTimeTracker(BuildContext context) {
    // final bloc = BlocProvider.of<StartWorkoutBloc>(context);
    return Container(
      width: double.infinity,
      color: ColorConstants.white,
      child: Column(
        children: [
          nextExercise != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TextConstants.nextExercise,
                      style: TextStyle(
                        color: ColorConstants.grey,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      nextExercise?.title ?? "",
                      style: TextStyle(
                        color: ColorConstants.textBlack,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6.5),
                    Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 6.5),
                    Text('00:${nextExercise!.minutes > 10 ? nextExercise!.minutes : '0${nextExercise!.minutes}'}')
                    // BlocBuilder<StartWorkoutBloc, StartWorkoutState>(
                    //   buildWhen: (_, currState) => currState is PlayTimerState || currState is PauseTimerState,
                    //   builder: (context, state) {
                    //     return StartWorkoutTimer(
                    //       time: bloc.time,
                    //       isPaused: !(state is PlayTimerState),
                    //     );
                    //   },
                    // ),
                  ],
                )
              : SizedBox.shrink(),
          const SizedBox(height: 18),
          _createButton(context),
        ],
      ),
    );
  }

  Widget _createButton(BuildContext context) {
    return FitnessButton(
      title: nextExercise != null ? TextConstants.next : 'Finish',
      onTap: () {
        if (nextExercise != null) {
          List<ExerciseData> exercisesList = BlocProvider.of<workout_bloc.WorkoutDetailsBloc>(context).workout.exerciseDataList;
          int currentExerciseIndex = exercisesList.indexOf(exercise);
          if (currentExerciseIndex < exercisesList.length - 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<workout_bloc.WorkoutDetailsBloc>(context),
                        child: StartWorkoutPage(
                          exercise: exercisesList[currentExerciseIndex + 1],
                          currentExercise: exercisesList[currentExerciseIndex + 1],
                          nextExercise: currentExerciseIndex + 2 < exercisesList.length ? exercisesList[currentExerciseIndex + 2] : null,
                        ),
                      )),
            );
          }
        } else {
          http.post(Uri.parse('http://127.0.0.1:5001/user/record?status=false&frequency=1000'))
          .then((response) {
            if (response.statusCode == 200) {
              // If the server did return a 200 OK response,
              // parse the JSON data and update the bloc's state
              print("ending successful");
            } else {
              // If the server did not return a 200 OK response,
              // throw an exception and handle it in the bloc
              // throw Exception('Failed to load data');
              print("ending error");
            }
          }).catchError((error) {
            // Handle errors in the bloc
            print("ending error");
          });
          final bloc = BlocProvider.of<StartWorkoutBloc>(context);
          bloc.stopTimer();
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class Step extends StatelessWidget {
  final String number;
  final String description;

  Step({required this.number, required this.description});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: ColorConstants.primaryColor.withOpacity(0.12),
          ),
          child: Center(child: Text(number, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(description)),
      ],
    );
  }
}
