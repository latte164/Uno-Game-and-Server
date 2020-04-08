class Card implements Comparable<Card> {
  
  //0 - red, 1 - yellow, 2 - green, 3- blue, 4 - special
  int cardColor;
  //one 0, two 1-9, two skip - 10, two draw two - 11, two reverse - 12
  //special: four wild - 0, four draw four - 1
  int cardNumber;
  
  Card(int cardColor, int cardNumber) {
    this.cardColor = cardColor;
    this.cardNumber = cardNumber;
  }
  
  Card(String card) {
    String[] components = card.split(":");
    this.cardColor = int(components[0]);
    this.cardNumber = int(components[1]);
  }
  
  void drawCard(float x, float y) {
    
    //card background
    switch(cardColor) {
      case 0:
        fill(232, 56, 32);
        break;
        
      case 1:
        fill(190, 190, 52);
        break;
        
      case 2:
        fill(33, 180, 57);
        break;
        
      case 3:
        fill(29, 119, 209);
        break;
        
      case 4:
        fill(25);
        break;
    }  
    rectMode(CENTER);
    strokeWeight(5);
    stroke(50);
    rect(x, y, 100, 150, 15);
    
    //text
    fill(225);
    textAlign(CENTER, CENTER);
    textSize(60);
    String text = "";
    
    if(cardColor == 4) {
      if(cardNumber == 0)
        text = "W";
      else if(cardNumber == 1)
        text = "+4";
    } else {
      
      if(cardNumber >= 0 && cardNumber <= 9)
        text = "" + cardNumber;
      else if(cardNumber == 10)
        text = "S";
      else if(cardNumber == 11)
        text = "+2";
      else if(cardNumber == 12)
        text = "R";
      
    }
    
    text(text, x, y);
    textSize(30);
    textAlign(LEFT);
    text(text, x-45, y-45);
    
  }
  
  public int compareTo(Card other) {
    
    if(this.cardColor < other.cardColor)
      return -1;
    else if(this.cardColor > other.cardColor)
      return 1;
    
    if(this.cardNumber < other.cardNumber)
      return -1;
    if(this.cardNumber > other.cardNumber)
      return 1;
      
    return 0;
    
  }
  
  public String toString() {
    return "" + cardColor + ":" + cardNumber;
  }
  
}