import java.net.*;

class Client {
  
  String address = "localhost", name;
  int port = 8192, ID = -1;
  boolean connected;
  
  GameController controller;
  
  DatagramSocket socket;
  InetAddress inet;
  
  Thread send, listen;
  
  Client(String name, GameController controller) {
    this.name = name;
    this.controller = controller;
    connected = this.openConnection();
    if(!connected)
      return;
    
    println("Attempting connection to " + address + ":" + port);
    String connection = "/c/" + name;
    send(connection, 1);
  }
  
  String receive() {
    byte[] data = new byte[1024];
    DatagramPacket packet = new DatagramPacket(data, data.length);
    
    try {
      socket.receive(packet);
    } catch(Exception e) {
      e.printStackTrace();
    }
    
    String message = new String(packet.getData());
    if(!message.startsWith("/i/"))  
      println("Received: " + message);
    
    return message;
    
  }
  
  void listen() {
    listen = new Thread("Listen") {
      public void run() {
        while(connected) {
          String message = client.receive().trim();
          
          if(message.startsWith("/c/")) {
            client.setID(Integer.parseInt(message.substring(3, message.length())));
            println("ID: " + ID);
          } else if(message.startsWith("/m/")) {
            String[] text = message.substring(3,message.length()).split("/");
            
            GameController cont = getController();
            if(text[0].equals("start")) {
              cont.setStarted(true);
              
              //println("fnweofewofe     " + text[1] + "    " + text[1].split(",").length); 
              String[] playerNames = text[1].split(",");
              String[] parsedPlayerNames = new String[playerNames.length];
              int[] playerCardNumbers = new int[playerNames.length];
              for(int i = 0; i < playerNames.length; i++) {
                if(playerNames[i].equals("")) continue;
                parsedPlayerNames[i] = playerNames[i];
                playerCardNumbers[i] = 7;
              }
              cont.playerNames = parsedPlayerNames;
              cont.playerCardNums = playerCardNumbers;
              
            } else if(text[0].equals("active")) {
              cont.setActive(true);
              
            } else if(text[0].equals("hand")) {
              String[] initCards = text[1].split(",");
              cont.activeCard = new Card(initCards[0]);
              for(int i = 1; i < initCards.length; i++) {
                if(initCards[i].equals("")) continue;
                cont.hand.add(new Card(initCards[i]));
              }
              
            } else if(text[0].equals("card")) {
              cont.hand.add(new Card(text[1]));
              
            } else if(text[0].equals("activeCard")) {
              cont.activeCard = new Card(text[1]);
              
            }
            
            
            
            setController(cont);
            
          } else if(message.startsWith("/i/")) {
            String text = "/i/" + client.ID;
            send(text, 1);
          }
        
      
        }
      }
    };
    listen.start();
  }
  
  void sendMessage(String message) {
    send(message, 0);
  }
  
   void send(String message, int type) { //types: 1-non normal (connect/disconnect/ping), 0-normal
    if(type == 0)
      message = "/m/" + ID + "/" + message;
    
    if(!message.startsWith("/i/"))
      println("Sending: " + message);
    send(message.getBytes());
  }
  
  void send(final byte[] data) { 
    send = new Thread("Send") {
      public void run() {
        DatagramPacket packet = new DatagramPacket(data, data.length, inet, port);
        
        try {
          socket.send(packet);
        } catch(Exception e) {
          e.printStackTrace();
        }
      
      }
    };
    send.start();
  }
  
  void closeSocket() {
    new Thread() {
      public void run() {
        synchronized(socket) {
          socket.close();
        }
      }
    }.start();
  }
  
  boolean openConnection() {
    try {
      socket = new DatagramSocket();
      inet = InetAddress.getByName(address);
    } catch(Exception e) {
      e.printStackTrace();
      return false;
    }
 
   return true; 
  }
  
  void setID(int ID) {
    this.ID = ID;
    if(this.ID == -1)
      connected = false;
    else if(this.ID == 0)
      controller.thisPlayerActive = true;
  }
  
  GameController getController() {
    return controller;
  }
  
  void setController(GameController newController) {
    controller = newController;
  }
  
}