// https://github.com/henrichen/weak
// utils.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
class X {
  final int value;
  X(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is X && value == other.value);

  @override
  String toString() => 'X$value';
}

class Y {
  String value;
  Y(int value) : value = '$value';

  @override
  String toString() => 'Y$value';
}
