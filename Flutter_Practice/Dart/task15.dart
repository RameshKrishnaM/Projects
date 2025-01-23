//1.-------------------------------------

import 'dart:io';

void main() {
  print('Enter the length of the list');
  int n = int.parse(stdin.readLineSync()!);
  print('Enter the List of values');
  List<int> nums = [];
  for (int i = 0; i < n; i++) {
    nums.add(int.parse(stdin.readLineSync()!));
  }
  print('Enter the Target Value');
  int target = int.parse(stdin.readLineSync()!);
  twoSum(nums, target);
}

void twoSum(List<int> nums, int target) {
  List<int> result = [];
  for (int i = nums.length - 1; i > 0; i--) {
    int c = 1;
    int res = 0;
    for (int j = i - 1; j > 0; j--) {
      res = nums[i] + nums[j];
      if (res < target) {
        nums[i] = res;
        continue;
      }
      if (res > target) {
        break;
      }
      if (res == target) {
        c = 0;
        result = [j, i];
        break;
      }
    }
    if (c == 0) {
      break;
    }
  }
  print(result);
}
