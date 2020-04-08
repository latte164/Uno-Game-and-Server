class GameController {
  
  int players = 0;
  int[] playerCardNums;
  String[] playerNames;
  ArrayList<Card> hand = new ArrayList<Card>();
  Card activeCard = new Card(4, 1);
  boolean gameOver = false, thisPlayerActive = false, started = false;
  
  boolean getActive() {
    return thisPlayerActive;
  }
  
  void setActive(boolean active) {
    thisPlayerActive = active;
  }
  
  boolean getStarted() {
    return started;
  }
  
  void setStarted(boolean started) {
    this.started = started;
  }
  
}