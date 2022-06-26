import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;
  setUp(() {
    inputConverter = InputConverter();
  });

  group("stringToUnsignedInt", () {
    test(
        "should return an integer when a string represents an unsigned integer",
        () async {
      // arrange
      const String str = "123";
      // act
      final result = inputConverter.inputToUnsignedInteger(str);
      // assert
      expect(result, const Right(123));
    });

    test("should return a failure when the string is not an integer", () async {
      // arrange
      const String str = "abc";
      // act
      final result = inputConverter.inputToUnsignedInteger(str);
      // assert
      expect(result, Left(InvalidInputFailure()));
    });

    test("should return a failure when the string is a negative integer",
        () async {
      // arrange
      const String str = "-157";
      // act
      final result = inputConverter.inputToUnsignedInteger(str);
      // assert
      expect(result, Left(InvalidInputFailure()));
    });
  });
}
