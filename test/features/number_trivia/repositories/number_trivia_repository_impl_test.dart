import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks(
    [NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo])
void main() {
  late NumberTriviaRepository repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDatasource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  const tNumber = 1;
  const tNumberTrivialModel =
      NumberTriviaModel(number: tNumber, text: 'test trivia');
  const NumberTrivia tNumberTrivia = tNumberTrivialModel;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });
  });

  group('device is online', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test(
        'should return remote data when the call to remote data source is success',
        () async {
      // arrange
      when(mockRemoteDataSource.getConcreteNumberTrivia(any))
          .thenAnswer((_) async => tNumberTrivialModel);
      // act
      final result = await repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
      expect(result, equals(const Right(tNumberTrivia)));
    });

    test(
        'should cache the data locally when the call to remote data source is success',
        () async {
      // arrange
      when(mockRemoteDataSource.getConcreteNumberTrivia(any))
          .thenAnswer((_) async => tNumberTrivialModel);
      // act
      final result = await repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
      verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivialModel));
    });
  });
}
