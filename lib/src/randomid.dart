import 'dart:math';

/*
Generate a random id comprised of:
 - A 9-digit hex integer timestamp of seconds since January 1, 1970
 - A 5-digit random hex integer

This makes IDs roughly sortable on their creation datetime while providing
a facility to prevent collisions.

These IDs are not going to be created often so 1-second resolution on the
timestamp is sufficient
*/

class RandomId{
  static String generate(){
    var epoch = new DateTime(1970);
    var secondsSince = new DateTime.now().toUtc().difference(epoch).inSeconds;
    var secondsSinceHex = _toPaddedHex(secondsSince, 9);

    var random = new Random();
    var randomInt = random.nextInt(1048576); //1048575 is the largest integer possible with a 5-digit hex value
    var randomIntHex = _toPaddedHex(randomInt, 5);

    return secondsSinceHex + randomIntHex;
  }

  static String _toPaddedHex(int value,int length){
    return value.toRadixString(16).padLeft(length,'0');
  }
}