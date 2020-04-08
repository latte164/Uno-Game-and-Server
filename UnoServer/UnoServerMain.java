//This client created with the help of TheCherno's Youtube chat networking tutorial

class UnoServerMain {
	
	private int port;
	UnoServer unoServer;

	public UnoServerMain(int port) {
		this.port = port;
		this.unoServer = new UnoServer(port);
	}

	public static void main(String[] args) {
		int port;
		if(args.length != 1) {
			System.out.println("only input the port on the comamnd line");
			return;
		}

		port = Integer.parseInt(args[0]);
		new UnoServerMain(port);

	}

}