void main(List<String> args) {
  var a = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];

  for (var i = 0; i < a.length - 1; i++) {
    for (var j = i; i < a.length - 1; i++) {}
  }
}
