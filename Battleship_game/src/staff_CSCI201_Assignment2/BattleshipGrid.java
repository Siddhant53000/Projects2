package staff_CSCI201_Assignment2;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.GridLayout;
import java.awt.Point;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

import javax.swing.BorderFactory;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;

@SuppressWarnings("serial")
public class BattleshipGrid extends JPanel {
	private static final ImageIcon water[];
	private JButton[][] grid;
	private ArrayList<Battleship> ships;
	
	private static final ImageIcon icons[];
	static{
		icons = new ImageIcon[7];
		icons[0] = new ImageIcon("src/A.png");
		icons[1] = new ImageIcon("src/B.png");
		icons[2] = new ImageIcon("src/C.png");
		icons[3] = new ImageIcon("src/D.png");
		icons[4] = new ImageIcon("src/Q.png");
		icons[5] = new ImageIcon("src/M.png");
		icons[6] = new ImageIcon("src/X.png");
		water = new ImageIcon[2];
		water[0] = new ImageIcon("src/animatedWater/water1.png");
		water[1] = new ImageIcon("src/animatedWater/water2.png");
	}
	
	BattleshipGrid() {
		grid = new JButton[10][10];
		ships = new ArrayList<Battleship>();
		
		setLayout(new GridLayout(11,11));
		for(int i = 0; i < 10; i++) {
			add(new JLabel("  "+Character.toString((char)(0x41+i))));//0x41 is 'A' increment by i to go down the alphabet
			for(int j = 0; j < 10; j++) {
				grid[j][i] = new JButton(icons[4]){
					public void paintComponent(Graphics g) {
						g.drawImage(water[WaterChanger.getFrame()].getImage(),0,0,null);
						super.paintComponent(g);
					}
				};
				grid[j][i].setBorder(BorderFactory.createLineBorder(Color.RED));
				grid[j][i].setBackground(new Color(0,0,0,0));
				add(grid[j][i]);
			}
		}
		
		add(new JLabel("")); //fill in the bottom left corner
		
		for(int i = 0; i < 9; i++) {
			add(new JLabel("  "+Character.toString((char)(0x31+i))));//0x31 is '1' increment by i to increase value
		}add(new JLabel("  "+Character.toString((char)(0x31))+Character.toString((char)(0x30))));// 0x30,0x31 = '1''0'
	}
	
	void addListenerToGridSpace(GridButtonListener gbl) {
		grid[gbl.getLocation().x][gbl.getLocation().y].addActionListener(gbl);
	}
	
	public ArrayList<Battleship> getListOfShips() {
		return this.ships;
	}
	
	boolean addShip(Battleship bs) {
		int x1 = (int) bs.getStartPoint().getX();
		int x2 = (int) bs.getEndPoint().getX();
		int y1 = (int) bs.getStartPoint().getY();
		int y2 = (int) bs.getEndPoint().getY();
		if(x1 < 0 || x1 > 9) return false;
		if(x2 < 0 || x2 > 9) return false;
		if(y1 < 0 || y1 > 9) return false;
		if(y2 < 0 || y2 > 9) return false;
		
		for(Point p : bs.getAllPoints()) {
			if (grid[p.x][p.y].getIcon() != icons[4]) return false;
		}
		ships.add(bs);
		for(Point p: bs.getAllPoints()) {
			grid[p.x][p.y].setIcon(icons[bs.getTag()-'A']);
		}
		return true;
	}
	
	void enableGrid(boolean b) {
		for(int i = 0; i < 10; i++) {
			for(int j = 0; j < 10; j++) {
				grid[j][i].setEnabled(b);
			}
		}
	}
	
	public boolean isOccupied(Point p) {
		if(grid[p.x][p.y].getIcon() == icons[4]) return false;
		else return true;
	}
	
	public int getShipCount() {
		return ships.size();
	}
	
	public void clearShipAt(Point location) {
		Battleship toRemove = null;
		for(Battleship bs : ships) {
			for(Point p : bs.getAllPoints()) {
				if (location.equals(p)) {
					toRemove = bs;
					break;
				}
			}
		}
		for(Point p : toRemove.getAllPoints()) {
			grid[p.x][p.y].setIcon(icons[4]);
		}
		ships.remove(toRemove);
	}
	
	public int getNumSunk() {
		int total = 0;
		for(Battleship b : ships) {
			if(b.isSunk()) total++;
		}
		return total;
	}
	
	/*public boolean hitCoord(String coord) {//don't need this anymore
		if(coord.length()<2 || coord.length()>3) return false;
		char y = coord.charAt(0);
		if(y <'A' || y > 'J') return false;
		
		String x;
		if(coord.charAt(1) <'1' || coord.charAt(1) > '9') return false;
		else x = ""+coord.charAt(1);
		if(coord.length() == 3) {
			if(coord.charAt(2) != '0') return false;
			else x+=coord.charAt(2);
		}
		
		int yPos = (int)(y-'A');
		int xPos = Integer.valueOf(x)-1;
		if(xPos >9) return false;
		
		return hitShips(new Point(xPos,yPos),true);
	}*/
	
	public boolean hitShips(Point point, boolean enemy,GameManager toRelayMessage) {
		SoundLibrary.playSoundAfterDelay("src/Sounds/cannon.wav", 0);
		if(!enemy) {//attacking the non-enemy grid
			Icon toTest = grid[point.x][point.y].getIcon();
			if(toTest == icons[5] || toTest == icons[6]) return false;
		} else {
			Icon toTest = grid[point.x][point.y].getIcon();
			if(toTest != icons[4]) return false;
		}
		boolean hit = false;
		for(Battleship bs : ships) {
			if(bs.attackPoint(point)) {
				SoundLibrary.playSoundAfterDelay("src/Sounds/explode.wav", 1500);
				if(enemy) {
					//grid[point.x][point.y].setIcon(icons[bs.getTag()-'A']);
					Animations.createAnimationWithJButton(grid[point.x][point.y], Animations.EXPLOSION, icons[bs.getTag()-'A'], 2300);
					toRelayMessage.logHit("Player",pointToCoord(point),bs.getTag());
				}
				else {
					//grid[point.x][point.y].setIcon(icons[6]);
					Animations.createAnimationWithJButton(grid[point.x][point.y], Animations.EXPLOSION, icons[6], 2300);
					toRelayMessage.logHit("Computer",pointToCoord(point),bs.getTag());
				}
				hit = true;
				if(bs.isSunk()) {
					SoundLibrary.playSoundAfterDelay("src/Sounds/sinking.wav", 1500+2300);
					if(enemy){
						toRelayMessage.sinkShip("Player","Computer",bs.getTag());
					}
					else{
						toRelayMessage.sinkShip("Computer","Player",bs.getTag());
					}
					for(Point p : bs.getAllPoints()) {
						if(enemy) {
							Animations.createAnimationWithJButton(grid[p.x][p.y], Animations.SINK, icons[bs.getTag()-'A'],1130);
						}
						else {
							Animations.createAnimationWithJButton(grid[p.x][p.y], Animations.SINK, icons[6],1130);
						}
							
					}
				}
				break;
			}
		}
		if(!hit){
			SoundLibrary.playSoundAfterDelay("src/Sounds/splash.wav", 1500);
			Animations.createAnimationWithJButton(grid[point.x][point.y], Animations.SPLASH, icons[5],1130);
			if(enemy){toRelayMessage.logHit("Player",pointToCoord(point),0);}
			else toRelayMessage.logHit("Computer",pointToCoord(point),0);
		}
		return true;
	}

	public void clearGrid() {
		ships.clear();
		for(int i = 0; i < 10; i++) {
			for(JButton square : grid[i]) {
				square.setIcon(icons[4]);
			}
		}
	}

	public boolean loadMap(File toLoad) {
		Scanner inputScan = null;
		try {
			inputScan = new Scanner(toLoad);
			
			char[][] inputMatrix = new char[10][10];
			
			for(int i = 0; i < 10; i++) {
				String temp = inputScan.nextLine();
				if(temp.length() != 10) return false;
				else inputMatrix[i] = temp.toCharArray();
			}
			
			ships.clear();
			
			ArrayList<Battleship> dShips = new ArrayList<Battleship>();
			ArrayList<Battleship> dShipsR = new ArrayList<Battleship>();
			
			Map<Character,Integer> charToSize = new HashMap<Character,Integer>();
			charToSize.put('A', 5);
			charToSize.put('B', 4);
			charToSize.put('C', 3);
			charToSize.put('D', 2);
			
			char currentHoriz = '#';
			char currentVerti = '#';
			char currentHorizR = '#';
			char currentVertiR = '#';
			int horizStreak = 0;
			int vertiStreak = 0;
			int horizStreakR = 0;
			int vertiStreakR = 0;
			
			int horizDCount = 0;
			int vertiDCount = 0;
			
			int charCount[] = new int[5];
			for(int i = 0; i < charCount.length; i++) charCount[i] = 0;
			
			for(int i = 0; i < 10; i++) {
				for(int j = 0; j < 10; j++) {
					
					if(inputMatrix[i][j]!='X') charCount[inputMatrix[i][j]-'A']++;
					
					if(inputMatrix[i][j] == currentHoriz) {
						horizStreak++;
						if(horizStreak == charToSize.get(currentHoriz)) {
							Battleship bs = new Battleship(currentHoriz,new Point(j-charToSize.get(currentHoriz)+1,i),new Point(j,i));
							if(currentHoriz == 'D') {
								dShips.add(bs);
								horizDCount++;
							}
							else ships.add(bs);
							currentHoriz = '#';
							horizStreak = 0;
						}
					} 
					else if(inputMatrix[i][j]!='X') {
						currentHoriz = inputMatrix[i][j];
						horizStreak = 1;
					} else {
						currentHoriz = '#';
						horizStreak = 0;
					}
					
					if(inputMatrix[9-i][9-j] == currentHorizR) {
						horizStreakR++;
						if(horizStreakR == 2) {
							dShipsR.add(new Battleship('D',new Point(9-j,9-i),new Point(9-j+2-1,9-i)));
							currentHorizR = '#';
							horizStreakR = 0;
						}
					} 
					else if(inputMatrix[9-i][9-j]=='D') {
						currentHorizR = 'D';
						horizStreakR = 1;
					} else {
						currentHorizR = '#';
						horizStreakR = 0;
					}
					
					if(inputMatrix[j][i] == currentVerti) {
						vertiStreak++;
						if(vertiStreak == charToSize.get(currentVerti)) {
							Battleship bs = new Battleship(currentVerti,new Point(i,j-charToSize.get(currentVerti)+1),new Point(i,j));
							if(currentVerti == 'D') {
								dShips.add(bs);
								vertiDCount++;
							}
							else ships.add(bs);
							currentVerti = '#';
							vertiStreak = 0;
						}
					}
					else if(inputMatrix[j][i]!='X') {
						currentVerti = inputMatrix[j][i];
						vertiStreak = 1;
					} else {
						currentVerti = '#';
						vertiStreak = 0;
					}
					
					if(inputMatrix[9-j][9-i] == currentVertiR) {
						vertiStreakR++;
						if(vertiStreakR == 2) {
							dShipsR.add(new Battleship('D',new Point(9-i,9-j),new Point(9-i,9-j+2-1)));
							currentVertiR = '#';
							vertiStreakR = 0;
						}
					}
					else if(inputMatrix[9-j][9-i]=='D') {
						currentVertiR = 'D';
						vertiStreakR = 1;
					} else {
						currentVertiR = '#';
						vertiStreakR = 0;
					}
					
				}
			}
			
			if(charCount['A'-'A'] != 5) return false;
			if(charCount['B'-'A'] != 4) return false;
			if(charCount['C'-'A'] != 3) return false;
			if(charCount['D'-'A'] != 4) return false;
			
			if(horizDCount == 2 && vertiDCount == 1) {
				int posToDestroy = -1;
				int pos = 0;
				for(Battleship b : dShips) {
						if(b.getStartPoint().x == b.getEndPoint().x) posToDestroy = pos;
					pos++;
				}
				if(posToDestroy != -1) dShips.remove(posToDestroy);
			}
			
			if(horizDCount == 1 && vertiDCount == 2) {
				int posToDestroy = -1;
				int pos = 0;
				for(Battleship b : dShips) {
						if(b.getStartPoint().y == b.getEndPoint().y) posToDestroy = pos;
					pos++;
				}
				if(posToDestroy != -1) dShips.remove(posToDestroy);
			}
			
			if(horizDCount == 2 && vertiDCount == 2) {
				int posToDestroy = -1;
				int pos = 0;
				for(Battleship b : dShips) {
						if(b.getStartPoint().y == b.getEndPoint().y) posToDestroy = pos;
					pos++;
				}
				if(posToDestroy != -1) dShips.remove(posToDestroy);
				posToDestroy = -1;
				pos = 0;
				for(Battleship b : dShips) {
						if(b.getStartPoint().y == b.getEndPoint().y) posToDestroy = pos;
					pos++;
				}
				if(posToDestroy != -1) dShips.remove(posToDestroy);
			}
			
			if(dShips.size()!=2) return false;
			if(dShips.get(0).getStartPoint().equals(dShips.get(1).getStartPoint())
					|| dShips.get(0).getEndPoint().equals(dShips.get(1).getEndPoint())
					|| dShips.get(0).getStartPoint().equals(dShips.get(1).getEndPoint())
					|| dShips.get(0).getEndPoint().equals(dShips.get(1).getStartPoint())) {
				dShips = dShipsR;
			}
			
			ships.addAll(dShips);
			
			return true;
		} catch (FileNotFoundException e) {
			System.out.println("File path is invalid!");
			return false;
		} finally {
			if(inputScan != null)
			inputScan.close();
		}
	}

	public static String pointToCoord(Point location) {
		String s = new String();
		s+= Character.toString((char) (location.y+'A'));
		s+= String.valueOf(location.x+1);
		return s;
	}

}