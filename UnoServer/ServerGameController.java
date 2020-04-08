import java.util.*;

class ServerGameController {
	
	class Card {
		int cardColor, cardNumber;
		Card(int cardColor, int cardNumber) {
			this.cardColor = cardColor;
			this.cardNumber = cardNumber;
		}
		Card(String card) {
			String[] vals = card.split(":");
			this.cardColor = Integer.parseInt(vals[0]);
			this.cardNumber = Integer.parseInt(vals[1]);
		}

		String getString() {
			return "" + cardColor + ":" + cardNumber;
		}
	}

	ArrayList<Card> deck, discardPile;
	int activeID = 0;
	int[] numOfCards;
	int numOfPlayers = 0;
	int direction = 0;
	String activeCard;

	public ServerGameController(int numOfPlayers) {

		this.numOfPlayers = numOfPlayers;
		numOfCards = new int[numOfPlayers];

		deck = new ArrayList<Card>();
		discardPile = new ArrayList<Card>();

		fillDeck();

	}

	public String drawCard() {
		if(deck.size() < 1) {
			deck = discardPile;
			Collections.shuffle(deck);
			discardPile = new ArrayList<Card>();
		}

		return deck.remove(0).getString();
	}

	public void discardActive() {
		discardPile.add(new Card(this.activeCard));
	}

	public void discardCard(String card) {
		discardPile.add(new Card(card));
	}

	private void fillDeck() {
		for(int i = 0; i < 5; i++) {
			if(i != 4) {
				for(int j = 0; j < 13; j++) {
					if(j == 0) {
						deck.add(new Card(i, j)); //only 1 zero
					} else {
						deck.add(new Card(i, j)); //two of everything else
						deck.add(new Card(i, j));
					}
				}
			} else {
				for(int j = 0; j < 4; j++) {
					deck.add(new Card(i, 0)); //four wilds and +4s
					deck.add(new Card(i, 1));
				}
			}
		}
		Collections.shuffle(deck);
	}

}