import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetRandomNumberTrivia, GetConcreteNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test("initial state should be empty", () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    test(
        "should call the input converter to validate and convert the string to an unsigned integer",
        () async {
      // arrange
      setupMockInputConverterSuccess(mockInputConverter, tNumberParsed);
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.inputToUnsignedInteger(any));
      // assert
      verify(mockInputConverter.inputToUnsignedInteger(tNumberString));
    });

    test("should emit [Error] when the input is invalid", () {
      // arrange
      when(mockInputConverter.inputToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
      // assert
      final expected = [
        Empty(),
        const Error(message: invalidInputFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test("should get data from the concrete use case", () async {
      // arrange
      setupMockInputConverterSuccess(mockInputConverter, tNumberParsed);
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      // assert
      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test("should emit [Loading, Loaded] when data is gotten successfully",
        () async {
      // arrange
      setupMockInputConverterSuccess(mockInputConverter, tNumberParsed);
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      // assert later
      final expected = [
        Empty(),
        Loading(),
        const Loaded(trivia: tNumberTrivia)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test("should emit [Loading, Error] when getting data fails", () async {
      // arrange
      setupMockInputConverterSuccess(mockInputConverter, tNumberParsed);
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(ServerFailure()));

      // assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: serverFailureMessage)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        "should emit [Loading, Error] with a proper message when getting data fails",
        () async {
      // arrange
      setupMockInputConverterSuccess(mockInputConverter, tNumberParsed);
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(CacheFailure()));

      // assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: cacheFailureMessage)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));
        // assert
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          const Error(message: serverFailureMessage),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          const Error(message: cacheFailureMessage),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}

void setupMockInputConverterSuccess(
    MockInputConverter mockInputConverter, int tNumberParsed) {
  when(mockInputConverter.inputToUnsignedInteger(any))
      .thenReturn(Right(tNumberParsed));
}
