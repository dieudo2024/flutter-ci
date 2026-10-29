import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ci_counter/counter.dart';

void main() {
  test('counter starts at zero', () {
    final counter = Counter();
    expect(counter.value, 0);
  });

  test('increment adds one', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });

  test('decrement subtracts one but never goes below zero', () {
    final counter = Counter();
    counter.increment();
    counter.decrement();
    expect(counter.value, 0);
    counter.decrement();
    expect(counter.value, 0);
  });

  test('reset returns a positive counter to zero', () {
    final counter = Counter();
    counter.increment();
    counter.increment();
    counter.reset();
    expect(counter.value, 0);
  });
}
