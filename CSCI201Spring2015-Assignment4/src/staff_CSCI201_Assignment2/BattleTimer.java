package staff_CSCI201_Assignment2;

import javax.swing.JLabel;

public class BattleTimer extends JLabel{
	private static final long serialVersionUID = -5745696336097989111L;
	private static final int MAX_TIME = 15;
	public int timeLeft;
	
	BattleTimer() {
		timeLeft = 0;
	}
	
	public void reset(){
		timeLeft = MAX_TIME;
		setTime();
	}
	
	public void setTime() {
		String text = String.valueOf(timeLeft);
		if (timeLeft < 10) text = "0" + text;
		setText("Timer - 0:"+text);
	}
	
	public void endTimer() {
		timeLeft = 0;
		setTime();
	}

	public void tickDown() {
		timeLeft--;
		setTime();
	}
	
	public int getTime() {
		return timeLeft;
	}
	
	public boolean isDone() {
		if(timeLeft < 0) return true;
		else return false;
	}
	
}
