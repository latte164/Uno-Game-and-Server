import java.net.*;

class ServerClient {
	
	public String name;
	public InetAddress address;
	public int port, attempt = 0;
	public final int ID;

	public ServerClient(String name, InetAddress address, int port, final int ID) {
		this.name = name;
		this.address = address;
		this.port = port;
		this.ID = ID;
	}

}