import java.net.*;
import java.lang.*;
import java.util.*;

class UnoServer implements Runnable{
	
	private final int MAX_ATTEMPT = 5;

	private List<ServerClient> clients = new ArrayList<ServerClient>();
	private List<Integer> clientResponse = new ArrayList<Integer>();

	private ServerGameController controller;

	private DatagramSocket socket;
	private int port;
	private boolean running = false;
	private Thread run, manage, send, receive;

	public UnoServer(int port) {
		this.port = port;

		try {
			this.socket = new DatagramSocket(port);
		} catch(Exception e) {
			e.printStackTrace();
			return;
		}

		this.run = new Thread(this, "Server");
		run.start();
	}

	@Override
	public void run() {
		running = true;
		System.out.println("Server started on port " + port);
		manageClients();
		receive();
	}

	private void manageClients() {
		manage = new Thread("Manage") {
			public void run() {
				while(running) {
					sendToAllElse("/i/server", -1);

					try {
						Thread.sleep(2000);
					} catch(Exception e) {
						e.printStackTrace();
					}

					for(int i = 0; i < clients.size(); i++) {
						ServerClient c = clients.get(i);
						if(!clientResponse.contains(c.ID)) {
							if(c.attempt >= MAX_ATTEMPT) {
								disconnect(c.ID, false);
							} else {
								System.out.println("Attempting connection to " + c.name + " (" + c.ID + ") - Attempt # " + (c.attempt+1));
								c.attempt++;
							}
						} else {
							clientResponse.remove(new Integer(c.ID));
							c.attempt = 0;
						}
					}

				}
			}
		};
		manage.start();
	}

	private void receive() {
		receive = new Thread("Receive") {
			public void run() {
				while(running) {

					byte[] data = new byte[1024];
					DatagramPacket packet = new DatagramPacket(data, data.length);

					try {
						socket.receive(packet);
					} catch(Exception e) {
						e.printStackTrace();
					}

					process(packet);

				}
			}
		};
		receive.start();
	}

	private void sendToAllElse(String message, int senderID) { //Use -1 as the senderID if you want to send to everyone
		if(!message.startsWith("/i/"))
			System.out.println("Sending: \"" + message + "\" to all except ID=" + senderID);

		for(int i = 0; i < clients.size(); i++) {
			ServerClient client = clients.get(i);

			if(client.ID == senderID)
				continue;

			send(message.getBytes(), client.address, client.port);
		}
	}

	private void sendToPlayer(String message, int destID) {
		ServerClient c = null;

		for(int i = 0; i < clients.size(); i++) {
			if(clients.get(i).ID == destID) {
				c = clients.get(i);
				break;
			}
		}

		System.out.println("Sending \"" + message + "\" to " + destID);
		send(message.getBytes(), c.address, c.port);
	}

	private void send(final byte[] data, final InetAddress address, final int port) {
		send = new Thread("Send") {
			public void run() {
				DatagramPacket packet = new DatagramPacket(data, data.length, address, port);
				try {	
					socket.send(packet);
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
		};
		send.start();
	}

	private void process(DatagramPacket packet) {
		String message = new String(packet.getData()).trim();
		if(!message.startsWith("/i/"))	
			System.out.println("Received: " + message);

		if(message.startsWith("/c/")) {
			int id = UniqueIdentifier.getIdentifier();
			System.out.println("ID: " + id);

			if(id != -1) {
				clients.add(new ServerClient(message.substring(3,message.length()), packet.getAddress(), packet.getPort(), id));
				System.out.println("Connected: " + message.substring(3,message.length()));
			} else {
				System.out.println(message.substring(3,message.length()) + " attempted to connect but the client max has been reached.");
			}

			String ID = "/c/" + id;
			send(ID.getBytes(), packet.getAddress(), packet.getPort());

		} else if(message.startsWith("/m/")) {
			message = message.substring(3, message.length());

			String[] messageArr = message.split("/");
			int senderID = Integer.parseInt(messageArr[0]);

			if(messageArr[1].equals("start")) {
				controller = new ServerGameController(clients.size());
				sendToPlayer("/m/active", 0);

				int players = clients.size();
				int[] playerCardNums;
				String[] playerNames;
				String activeCard = controller.drawCard();
				controller.activeCard = activeCard;

				String sendText = "/m/start/";
				for(int i = 0; i < clients.size(); i++) {

					sendText += clients.get(i).name+",";

					String hand = "/m/hand/"+activeCard+",";
					for(int j = 0; j < 7; j++) {
						hand += controller.drawCard() + ",";
					}
					sendToPlayer(hand, clients.get(i).ID);
				}
				sendToAllElse(sendText, -1);

			} else if(messageArr[1].equals("drawCard")) {
				sendToPlayer("/m/card/" + controller.drawCard(), senderID);

			} else if(messageArr[1].equals("playCard")) {
				controller.discardActive();
				controller.activeCard = messageArr[2];
				sendToAllElse("/m/activeCard/"+controller.activeCard, -1);

				//decipher consequences of the card
				String[] vals = controller.activeCard.split(":");
				int cardColor = Integer.parseInt(vals[0]);
				int cardNumber = Integer.parseInt(vals[1]);

				ServerClient nextActive = getNextActive(senderID);

				if(cardColor == 4) {
					if(cardNumber == 1) {
						for(int i = 0;i < 4; i++) {
							distCard(nextActive.ID, controller.drawCard());
						}
						nextActive = getNextActive(nextActive.ID);
					}
				} else {

					if(cardNumber == 10) {
						nextActive = getNextActive(nextActive.ID);
					} else if(cardNumber == 11) {
						for(int i = 0;i < 2; i++) {
							distCard(nextActive.ID, controller.drawCard());
						}
						nextActive = getNextActive(nextActive.ID);
					} else if(cardNumber == 12) {
						controller.direction = (controller.direction+1)%2;
						nextActive = getNextActive(senderID);
					}

				}

				//determine new active player
				System.out.println("Sending active to " + nextActive.name);
				sendToPlayer("/m/active", nextActive.ID);

			} else if(messageArr[1].equals("winner")) {
				//send message to clients?
				endGame();

			}

		} else if(message.startsWith("/d/")) {

			String id = message.substring(3, message.length());
			disconnect(Integer.parseInt(id), true);

		} else if(message.startsWith("/i/")) {

			clientResponse.add(Integer.parseInt(message.substring(3,message.length())));

		} else {
			System.out.println(message);
		}

	}

	private ServerClient getNextActive(int currID) {
		int currClientInd = 0;
		for(int i = 0; i < clients.size(); i++) {
			if(clients.get(i).ID == currID) {
				currClientInd = i;
				break;
			}
		}

		ServerClient next = null;
		if(controller.direction == 0) {
			next = clients.get((currClientInd+1) % clients.size());
			while(next == null) {
				currClientInd++;
				next = clients.get((currClientInd+1) % clients.size());
			}
		}  else {
			next = clients.get((currClientInd-1) % clients.size());
			while(next == null) {
				currClientInd--;
				next = clients.get((currClientInd-1) % clients.size());
			}
		}

		return next;
	}

	private void distCard(int ID, String card) {
		sendToPlayer("/m/card/" + card, ID);
	}

	private void endGame() {
		running = false;
		System.exit(0);
	}

	private void disconnect(int id, boolean status) {
		ServerClient c = null;
		for(int i = 0; i < clients.size(); i++) {
			if(clients.get(i).ID == id) {
				c = clients.get(i);
				clients.remove(i);
				UniqueIdentifier.returnID(c.ID);
				break;
			}
		}

		String message = "";
		if(status) {
			message = "Client " + c.name + " (" + c.ID + ") Disconnected"; 
		} else {
			message = "Client " + c.name + " (" + c.ID + ") Timed Out";
		}
		System.out.println(message);

	}

}