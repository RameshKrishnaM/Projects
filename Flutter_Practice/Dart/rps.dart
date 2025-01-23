import 'dart:io';
import 'dart:math';

void main() {
  print("Welcome to the Game!!!...Rock Paper Scissor...");
  Random r = Random();
  List l1 = ['R', 'P', 'S'];
  int chance = 10;
  int noOfChance = 0;
  int hPoint = 0;
  int cPoint = 0;

  while (noOfChance < chance) {
    print("Enter R for Rock,P for Paper,S for Scissors");
    String? val = stdin.readLineSync();
    var choice = l1[r.nextInt(l1.length)];
    if (val == choice) {
      print('User Input : $val and Computer input : $choice');
      print("Tie : Both gets 0 points");
    }
    //Val = R
    else if (val == 'R' && choice == 'P') {
      print('User Input : $val and Computer input : $choice');
      print('Computer Won ${cPoint += 1}');
    } else if (val == 'R' && choice == 'S') {
      print('User Input : $val and Computer input : $choice');
      print('User Won ${hPoint += 1}');
    }
    //val = P
    else if (val == 'P' && choice == 'R') {
      print('User Input : $val and Computer input : $choice');
      print('User won ${hPoint += 1}');
    } else if (val == 'P' && choice == 'S') {
      print('User Input : $val and Computer input : $choice');
      print('Computer won ${cPoint += 1}');
    }
    //val = S
    else if (val == 'S' && choice == 'R') {
      print('User Input : $val and Computer input : $choice');
      print('Computer won ${cPoint += 1}');
    } else if (val == 'S' && choice == 'P') {
      print('User Input : $val and Computer input : $choice');
      print('User won ${hPoint += 1}');
    } else {
      print("Invalid Choice!!!");
    }
    noOfChance++;
    print('${chance - noOfChance} left out of $chance');
  }
  print('Game Over!...');
  print('Total :');
  print('Your Score :$hPoint');
  print('Computer Score :$cPoint');
  if (hPoint == cPoint) {
    print('Both are Tie');
  } else if (hPoint > cPoint) {
    print(
        'You Win with a score of $hPoint against computer\'s score of $cPoint ');
  } else {
    print(
        'computer wins with a score of $cPoint against your score of $hPoint');
  }
  print('Thank You!!!...');
}
