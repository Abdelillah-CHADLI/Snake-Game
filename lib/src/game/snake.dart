import 'position.dart';
import 'direction.dart';

class Snake {
  final List<Position> body;
  Direction direction;
  bool _growOnNextMove = false;

  Snake({required List<Position> initialBody, required this.direction}) : body = List.of(initialBody);

  Position get head => body.first;

  void setDirection(Direction newDirection) {
    if (!newDirection.isOpposite(direction)) {
      direction = newDirection;
    }
  }

  void grow() {
    _growOnNextMove = true;
  }

  void move(Position newHead) {
    body.insert(0, newHead);
    if (_growOnNextMove) {
      _growOnNextMove = false;
    } else {
      body.removeLast();
    }
  }

  bool contains(Position p) => body.contains(p);

  bool hitsSelf() {
    return body.skip(1).contains(head);
  }
}
