import 'dart:math';


/*
Generate a random id comprised of:
 - A 10-digit hex integer timestamp of seconds since January 1, 2010
 - A 6-digit random hex integer

This makes IDs roughly sortable on their creation datetime while providing
a facility to prevent collisions.

These IDs are not going to be created often so 1-second resolution on the
timestamp is sufficient
 */
class RandomId{
  static String generate(){
    var epoch = new DateTime(2010);
    var secondsSince = new DateTime.now().toUtc().difference(epoch).inSeconds;
    var secondsSinceHex = _toPaddedHex(secondsSince, 10);

    var random = new Random();
    var randomInt = random.nextInt(16777216); //16777215 is the largest integer possible with a 6-digit hex value
    var randomIntHex = _toPaddedHex(randomInt, 6);

    return secondsSinceHex + randomIntHex;
  }

  static String _toPaddedHex(int value,int length){
    String hex = value.toRadixString(16);
    hex = hex.padLeft(length,'0');
    return hex.substring(hex.length - length, length);
  }
}