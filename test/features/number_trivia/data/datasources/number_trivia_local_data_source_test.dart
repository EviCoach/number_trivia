import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  NumberTriviaLocalDataSourceImpl datasource;
  MockSharedPreferences mockSharedPreferences;
  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  group("getLastNumberTrivia", () {
    test(
        "should return NumberTrivia model from sharedPreferences when there is one in the cache",
        () async {
      // arrange
      // when()
      // act

      // assert
    });
  });
}
