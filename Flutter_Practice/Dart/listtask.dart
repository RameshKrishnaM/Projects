void main(List<String> args) {
  List a = [
    1,
    2,
    3,
    4,
    {"name": "Ramesh"},
  ];
  List b = [...a];
  b[4]["name"] = "Krishna";
  b[3] = 9;
  print(a);
  print(b);
}
