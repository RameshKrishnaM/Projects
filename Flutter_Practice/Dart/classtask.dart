class A {
  int a = 10;
}

void main(List<String> args) {
  print(A().a);
  A a = A();
  a.a = 30;
  print(a.a);
}
