enum Priority{
  Note,
  Caution,
  Warning,
}

class Note implements Comparable<Note>{
  final Priority priority;
  final String text;

  Note(this.priority,this.text){
    assert (priority != null && text != null);
  }

  int compareTo(Note other){
    if (other.priority.index > this.priority.index)
      return 1;
    else if (other.priority.index < this.priority.index)
      return -1;

    return this.text.compareTo(other.text);
  }
}