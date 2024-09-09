  import 'dart:math';

isLevelCompleted(int level, int attempts)  {
   int numberOfDisks = level + 1;
   num bestCounter = pow(2, numberOfDisks) - 1;

   return attempts == bestCounter;
  }
