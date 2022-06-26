import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = "Server failure";
const String cacheFailureMessage = "Cache failure";
const String invalidInputFailureMessage =
    "Invalid input - The number must be a positive number or zero";

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<GetTriviaForConcreteNumber>(_onGetTrivia);
    on<GetTriviaForRandomNumber>(_onGetTrivia);
  }

  _onGetTrivia(event, emit) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.inputToUnsignedInteger(event.numberString);
      yield* inputEither.fold((failure) async* {
        yield const Error(message: invalidInputFailureMessage);
      }, (integer) async* {
        yield Loading();
        final failureOrTrivia =
            await getConcreteNumberTrivia(Params(number: integer));
        yield _eitherLoadedOrErrorState(failureOrTrivia);
      });
    } else if (event is GetTriviaForRandomNumber) {
      yield Loading();
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      yield _eitherLoadedOrErrorState(failureOrTrivia);
    }
  }

  NumberTriviaState _eitherLoadedOrErrorState(
      Either<Failure, NumberTrivia> failureOrTrivia) {
    return failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (trivia) => Loaded(trivia: trivia));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return serverFailureMessage;
    }
    if (failure is CacheFailure) {
      return cacheFailureMessage;
    }

    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
