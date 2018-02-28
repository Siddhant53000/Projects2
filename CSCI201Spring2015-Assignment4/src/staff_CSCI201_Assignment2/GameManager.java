package staff_CSCI201_Assignment2;

import java.awt.Color;
import java.awt.Point;

import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.ScrollPaneConstants;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;
import javax.swing.text.DefaultCaret;

public class GameManager extends JPanel implements Runnable{
	private static final long serialVersionUID = 4739524770269580201L;
	public final BattleTimer battleTimer;
	private JTextArea display;
	public volatile boolean running;
	private boolean enemyMoved;
	private boolean playerMoved;
	
	private final BattleshipGrid player;
	private final BattleshipGrid enemy;
	private final BattleshipFrame frame;
	private int computerAttack;
	
	private int round;
	
	GameManager(BattleTimer bt, BattleshipGrid player, BattleshipGrid enemy, BattleshipFrame battleshipFrame) {
		this.setBorder(new TitledBorder(new EtchedBorder(), "Game Log"));
		this.setBackground(Color.YELLOW);
		display = new JTextArea ( 4, 24 );
	    display.setEditable ( false );
	    DefaultCaret caret = (DefaultCaret)display.getCaret();
	    caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
	    JScrollPane scroll = new JScrollPane ( display );
	    scroll.setVerticalScrollBarPolicy ( ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS );
	    this.add ( scroll );
		
		battleTimer = bt;
		round = 0;
		this.player = player;
		this.enemy = enemy;
		this.frame = battleshipFrame;
	}
	
	@Override
	public void run() {
		running = true;
		newRound();
		while(running) {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			battleTimer.tickDown();
			if(battleTimer.isDone()) {
				newRound();//announce new round, clear move restrictions, reset timer
			}
			if(battleTimer.getTime() == computerAttack) {
				Point p;
				do{
					p = new Point(Utils.randInt(0, 9),Utils.randInt(0, 9));
				} while(!player.hitShips(p,false,this));
			}
			if(battleTimer.getTime() == 3) {
				logNewInfo("Warning! 3 seconds left in the round!");
			}
			if(playerMoved && enemyMoved) {
				newRound();
			}
			checkForWin();
			if(!running) {
				battleTimer.reset();
			}
		}
	}
	
	public void endGame() {
		running = false;
		battleTimer.reset();
		round = 0;
	}
	
	private void newRound() {
		battleTimer.reset();//go back to 0:15
		round++;
		logNewInfo("Round "+round);
		playerMoved = false;
		enemyMoved = false;
		computerAttack = Utils.randInt(0, 17);//small chance of missing round
	}
	
	public void logHit(String player, String coord, int shipType) {
		String result = " and missed!";
		if(shipType>0) {
			result = " and hit a";
			if(shipType == 'A') result += "n Aircraft Carrier!";
			if(shipType == 'B') result += " Battleship!";
			if(shipType == 'C') result += " Cruiser!";
			if(shipType == 'D') result += " Destroyer!";
		}
		String timeLeft = String.valueOf(battleTimer.timeLeft);
		if(battleTimer.timeLeft < 10) timeLeft = "0"+timeLeft;
		logNewInfo(player+" hit "+ coord + result + "(0:"+ timeLeft +")");
		if(player.equals("Player")) playerMoved = true;
		if(player.equals("Computer")) enemyMoved = true;
	}
	
	public void logNewInfo(String info) {
		//print info, as well as the time from the battleTimer
		display.append(info+'\n');
	}

	public boolean enemyCanMove() {
		return !enemyMoved;
	}
	
	public boolean playerCanMove() {
		return !playerMoved;
	}

	public void sinkShip(String player, String enemy, char tag) {
		String msg = player+" sunk "+enemy+"'s ";
		if(tag == 'A') msg += "Aircraft Carrier!";
		if(tag == 'B') msg += "Battleship!";
		if(tag == 'C') msg += "Cruiser!";
		if(tag == 'D') msg += "Destroyer!";
		logNewInfo(msg);
	}
	
	private void checkForWin() {
		boolean playerWins = false, opponentWins = false;
		if(player.getNumSunk() == 5) {
			opponentWins = true;
		}
		if(enemy.getNumSunk() == 5) {
			playerWins = true;
		}
		
		if(playerWins || opponentWins) {
			while(Animations.numPlaying() > 0) {
				try {
					Thread.sleep(20);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			if(playerWins && opponentWins) {
				JOptionPane.showMessageDialog(null,"The game is a tie!", "Game Over!",JOptionPane.PLAIN_MESSAGE);
			} else if(playerWins) {
				JOptionPane.showMessageDialog(null,"You won!", "Game Over!",JOptionPane.PLAIN_MESSAGE);
			} else if (opponentWins) {
				JOptionPane.showMessageDialog(null,"You lost!", "Game Over!",JOptionPane.PLAIN_MESSAGE);
			}
			frame.enterEditMode();
		}
	}
}
