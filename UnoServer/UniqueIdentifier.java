import java.util.*;

public class UniqueIdentifier {
	
	private static List<Integer> ids = new ArrayList<Integer>();
	private static List<Integer> retIds = new ArrayList<Integer>();
	private static final int RANGE = 5; //Number of clients allowed

	private static int index = 0;

	static {
		for(int i = 0; i < RANGE; i++) {
			ids.add(i);
		}
	}

	private UniqueIdentifier() {

	}

	public static void returnID(int id) {
		retIds.add(id);
	}

	public static int getIdentifier() {
		if(index > ids.size() - 1 && retIds.size() == 0)
			return -1;
		else if(retIds.size() != 0) {
			int id = retIds.get(0);
			retIds.remove(0);
			return id;
		}

		return ids.get(index++);
	}

}