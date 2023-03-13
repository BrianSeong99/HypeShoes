import 'package:fitness_flutter/data/exercise_data.dart';
import 'package:fitness_flutter/screens/start_workout/bloc/start_workout_bloc.dart';
import 'package:fitness_flutter/screens/start_workout/widget/start_workout_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:fitness_flutter/screens/start_workout/data/live_data.dart';

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
        final bloc = StartWorkoutBloc();
        bloc.chartData = [
          LiveData(time: 0, value: 42),
          LiveData(time: 1, value: 47),
          LiveData(time: 2, value: 43),
          LiveData(time: 3, value: 49),
          LiveData(time: 4, value: 54),
          LiveData(time: 5, value: 41),
          LiveData(time: 6, value: 58),
          LiveData(time: 7, value: 51),
          LiveData(time: 8, value: 98),
          LiveData(time: 9, value: 41),
          LiveData(time: 10, value: 53),
          LiveData(time: 11, value: 72),
          LiveData(time: 12, value: 86),
          LiveData(time: 13, value: 52),
          LiveData(time: 14, value: 94),
          LiveData(time: 15, value: 92),
          LiveData(time: 16, value: 86),
          LiveData(time: 17, value: 72),
          LiveData(time: 18, value: 94)
        ];
        Timer.periodic(const Duration(seconds: 1), (timer) {
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
