// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';

class IsSelectedCubit extends Cubit<bool> {
  IsSelectedCubit() : super(false);

  void chengeSelected(bool pos) {
    emit(pos);
  }
}

