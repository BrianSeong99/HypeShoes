import 'package:fitness_flutter/data/exercise_data.dart';
import 'package:fitness_flutter/screens/start_workout/bloc/start_workout_bloc.dart';
import 'package:fitness_flutter/screens/start_workout/widget/start_workout_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:fitness_flutter/screens/start_workout/data/live_data.dart';
import 'package:http/http.dart' as http;

class StartWorkoutPage extends StatelessWidget {
  final ExerciseData exercise;
  final ExerciseData currentExercise;
  final ExerciseData? nextExercise;

  StartWorkoutPage(
      {required this.exercise,
      required this.currentExercise,
      required this.nextExercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContext(context),
    );
  }

  BlocProvider<StartWorkoutBloc> _buildContext(BuildContext context) {
    return BlocProvider<StartWorkoutBloc>(
      create: (context) {
        // var request = http.Request('POST', Uri.parse('http://127.0.0.1:5001/user/record?status=true&frequency=1000'));
        // request.send();
        final bloc = StartWorkoutBloc();
        http.post(Uri.parse('http://127.0.0.1:5001/user/record?status=true&frequency=' + bloc.frequency.toString()))
          .then((response) {
          if (response.statusCode == 200) {
            // If the server did return a 200 OK response,
            // parse the JSON data and update the bloc's state
            print("beginning successful");
          } else {
            // If the server did not return a 200 OK response,
            // throw an exception and handle it in the bloc
            // throw Exception('Failed to load data');
            print("beginning error");
          }
        }).catchError((error) {
          // Handle errors in the bloc
          print("beginning error");
        });
        bloc.leftSensor0 = [
          LiveData(time: 0, value: 0),
          LiveData(time: 1, value: 0),
          LiveData(time: 2, value: 0),
          LiveData(time: 3, value: 0),
          LiveData(time: 4, value: 0),
          LiveData(time: 5, value: 0),
          LiveData(time: 6, value: 0),
          LiveData(time: 7, value: 0),
          LiveData(time: 8, value: 0),
          LiveData(time: 9, value: 0),
          LiveData(time: 10, value: 0),
          LiveData(time: 11, value: 0),
          LiveData(time: 12, value: 0),
          LiveData(time: 13, value: 0),
          LiveData(time: 14, value: 0),
          LiveData(time: 15, value: 0),
          LiveData(time: 16, value: 0),
          LiveData(time: 17, value: 0),
          LiveData(time: 18, value: 0)
        ];
        bloc.leftSensor1 = bloc.leftSensor0;
        bloc.leftSensor2 = bloc.leftSensor0;
        bloc.leftSensor3 = bloc.leftSensor0;
        bloc.leftAccel0 = bloc.leftSensor0;
        bloc.leftAccel1 = bloc.leftSensor0;
        bloc.leftAccel2 = bloc.leftSensor0;
        bloc.leftGyro0 = bloc.leftSensor0;
        bloc.leftGyro1 = bloc.leftSensor0;
        bloc.leftGyro2 = bloc.leftSensor0;
        bloc.rightSensor0 = bloc.leftSensor0;
        bloc.rightSensor1 = bloc.leftSensor0;
        bloc.rightSensor2 = bloc.leftSensor0;
        bloc.rightSensor3 = bloc.leftSensor0;
        bloc.rightAccel0 = bloc.leftSensor0;
        bloc.rightAccel1 = bloc.leftSensor0;
        bloc.rightAccel2 = bloc.leftSensor0;
        bloc.rightGyro0 = bloc.leftSensor0;
        bloc.rightGyro1 = bloc.leftSensor0;
        bloc.rightGyro2 = bloc.leftSensor0;
        bloc.timer = Timer.periodic(Duration(milliseconds: bloc.frequency), (timer) {
          bloc.updateDataSource();
        });
        return bloc;
      },
      child: BlocConsumer<StartWorkoutBloc, StartWorkoutState>(
        buildWhen: (_, currState) => currState is StartWorkoutInitial,
        builder: (context, state) {
          return StartWorkoutContent(
            exercise: exercise,
            nextExercise: nextExercise,
          );
        },
        listenWhen: (_, currState) => currState is BackTappedState,
        listener: (context, state) {
          if (state is BackTappedState) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
