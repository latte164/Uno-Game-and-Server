
int players = 0;
int[] playerCardNums;
String[] playerNames;
Card activeCard = new Card(4, 1);
Player player;

GameController controller;
Client client;
Thread listen;

void setup() {
  
  size(1000, 900);
  player = new Player();
  
  /*for(int i = 0; i < 20; i++) {
    Card c = new Card(int(random(4)), int(random(13)));
    player.addCard(c);
  }*/
  
  controller = new GameController();
  client = new Client(player.name, controller);
  
  listen = new Thread("Window Listen") {
    public void run() {
      client.listen();
    }
  };
  listen.start();
  
  prepareExitHandler();
  
}

void draw() {

  background(100, 50, 50);
  
  player.active = client.getController().thisPlayerActive;
  activeCard = client.getController().activeCard;
  player.setHand(client.getController().hand);
  playerNames = client.getController().playerNames;
  playerCardNums = client.getController().playerCardNums;
  
  activeCard.drawCard(width/2 - 75, height/1.75);
  drawCardBack(width/2 + 75, height/1.75);
  player.drawHand(width, height);
  
  drawOpponents();
  
  if(!client.connected) {
    fill(225);
    textSize(70);
    textAlign(CENTER, CENTER);
    text("Not Connected", width/2, height/2);
  } else if(!client.getController().started) {
    fill(0);
    rectMode(CENTER);
    rect(width/2, height/2, 300, 100, 5);
    fill(225);
    textSize(40);
    textAlign(CENTER, CENTER);
    text("Start Game", width/2, height/2);
  }
  
}


private void prepareExitHandler() {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      String disconnect = "/d/" + client.ID;
      client.send(disconnect, 1);
      client.closeSocket();
      println("Closing Uno");
    }
  }));
}


void drawOpponents() {
  
  float y = height/10;
  textSize(40);
  fill(225);
  for(int i = 0; i < playerNames.length; i++) {
    if(playerNames[i].equals(player.name)) continue;
    
    text(playerNames[i] + " - Card Count: " + playerCardNums[i], width/2, y);
    y += height/20;
  }
  
}

void drawCardBack(float x, float y) {
  
  //card background
  fill(25); 
  rectMode(CENTER);
  strokeWeight(5);
  stroke(50);
  rect(x, y, 100, 150, 15);
  
  //text
  fill(225);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Deck", x, y);
  
}

void mouseReleased() {
  
  if(!client.getController().started) {
    if(mouseY >= height/2-50 && mouseY <= height/2+50) {
      if(mouseX >= width/2-150 && mouseX <= width/2+150) {
        
        client.sendMessage("start");
        
      }
    }
  } else if(player.active) {
    
    if(mouseY <= height/1.75 + 75 && mouseY >= height/1.75 - 75) {
      if(mouseX <= width/2 + 75+75 && mouseX >= width/2 + 75-75) {
        client.sendMessage("drawCard");
      }
    }
    
    if(mouseY <= height-75 && mouseY >= height-(150+75)) {
      Card clicked = player.getCardClicked(int(mouseX));
      
      if(clicked != null) {
        //send the server
        //change active
        
        if(clicked.cardColor == 4 || activeCard.cardColor == 4 || clicked.cardColor == activeCard.cardColor || clicked.cardNumber == activeCard.cardNumber) {
          client.sendMessage("playCard/" + clicked.toString());
          player.removeCard(clicked);
          player.active = false;
          
          if(player.hand.size() == 0)
            client.sendMessage("winner");          
          
        }
        
      }
      
    }
    
  }
  
}