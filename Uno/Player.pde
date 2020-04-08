import java.util.*;

class Player {
  
  String[] namePool = {"Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliett"};
  
  String name = "";
  ArrayList<Card> hand;
  boolean active, handEmpty;
  
  Player() {
    
    hand = new ArrayList<Card>();
    active = false;
    handEmpty = false;
    
    int num = int(random(2, namePool.length - 3));
    for(int i = 0; i < num; i++)
      name += namePool[int(random(namePool.length))];
    
  }
  
  void setHand(ArrayList<Card> hand) {
    this.hand = hand;
    Collections.sort(hand);
  }
  
  void addCard(Card c) {
    hand.add(c);
    Collections.sort(hand);
  }
  
  ArrayList<Integer> locOfCards;
  void drawHand(float winWidth, float winHeight) {
    
    locOfCards = new ArrayList<Integer>();
    
    float buffer = 50;
    if(hand.size() >= 18)
      buffer = 25;
    
    float y = winHeight - 150;
    float x = winWidth/2 - hand.size()/2*buffer;
    
    for(int i = 0; i < hand.size(); i++) {
      hand.get(i).drawCard(x, y);
      locOfCards.add(int(x)-50);
      x += buffer;
    }
    
    if(this.active)
      fill(0, 255, 0);
    textSize(50);
    textAlign(CENTER, TOP);
    text(name, winWidth/2, winHeight - 70);
    
  }
  
  void removeCard(Card c) {
    hand.remove(c);
  }
  
  Card getCardClicked(int x) {
    
    for(int i = 0; i < locOfCards.size(); i++) {
      if(x >= locOfCards.get(i) && i+1 <= locOfCards.size()-1 && x < locOfCards.get(i+1))
        return hand.get(i);
      else if(i+1 > locOfCards.size()-1 && x <= locOfCards.get(i) + 100)
        return hand.get(i);        
    }
    
    return null;
    
  }
  
}