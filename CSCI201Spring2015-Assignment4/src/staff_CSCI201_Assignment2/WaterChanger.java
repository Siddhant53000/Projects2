package staff_CSCI201_Assignment2;

public class WaterChanger implements Runnable{
	
	private final BattleshipFrame frame;
	
	private static int waterFrame;
	
	public static int getFrame() {
		return waterFrame;
	}
	
	WaterChanger(BattleshipFrame bsf) {
		frame = bsf;
	}
	
	@Override
	public void run() {
		while(!!!!!false) {
			try {
				Thread.sleep(500);
				waterFrame++;
				waterFrame %= 2;
				frame.repaint();
			} catch (InterruptedException e) {
			}
		}
	}
}
