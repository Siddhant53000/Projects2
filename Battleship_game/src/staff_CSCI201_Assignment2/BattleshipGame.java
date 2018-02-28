package staff_CSCI201_Assignment2;

public class BattleshipGame {
	
	//public static Scanner scan = new Scanner(System.in);
	
	private BattleshipFrame bsf;
	
	BattleshipGame() {
		bsf = new BattleshipFrame();
		bsf.enterEditMode();
		Thread t = new Thread(new WaterChanger(bsf));
		t.start();
	}
	
	public static void main(String[] args) {
		new BattleshipGame();
	}

}
