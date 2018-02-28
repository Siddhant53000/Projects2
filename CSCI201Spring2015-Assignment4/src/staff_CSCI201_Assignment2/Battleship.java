package staff_CSCI201_Assignment2;

import java.awt.Point;
import java.util.ArrayList;

public class Battleship {
	private Point startPoint;
	private Point endPoint;
	private char tag;
	//private static final String[] NAMES = {"Aircraft Carrier", "Battleship", "Cruiser", "Destroyer"};
	

	class HitPoint extends Point{
	private static final long serialVersionUID = -6301467349152870140L;
	boolean hit; HitPoint(int x, int y){super(x,y);hit=false;}}
	private ArrayList<HitPoint> points;
	private int hp;
	public Battleship(char tag, Point startPoint, Point endPoint) {
		this.tag = tag;
		if((startPoint.x < endPoint.x) || (startPoint.y < endPoint.y)) {
			this.startPoint = startPoint;
			this.endPoint = endPoint;
		} else {
			this.startPoint = endPoint;
			this.endPoint = startPoint;
		}
		
		points = new ArrayList<HitPoint>();
		Point toAdd = new Point(this.startPoint.x,this.startPoint.y);
		if(this.startPoint.x == this.endPoint.x) {
			while(toAdd.y!=this.endPoint.y) {
				points.add(new HitPoint(toAdd.x,toAdd.y));
				toAdd.y++;
			}
			points.add(new HitPoint(toAdd.x,toAdd.y));
		}
		else if(this.startPoint.y == this.endPoint.y) {
			while(toAdd.x!=this.endPoint.x) {
				points.add(new HitPoint(toAdd.x,toAdd.y));
				toAdd.x++;
			}
			points.add(new HitPoint(toAdd.x,toAdd.y));
		}
		hp = points.size();
	}
	
	public boolean attackPoint(Point point) {
		boolean gotHit = false;
		for(HitPoint hitPoint: points) {
			if(hitPoint.equals(point)) {
				hitPoint.hit = true;
				gotHit = true;
				//System.out.println("You hit a "+NAMES[tag-'A']+"!");
				hp--;
				//if(hp == 0) System.out.println("You have sunken a "+NAMES[tag-'A']+"!");
			}
		}
		return gotHit;
	}
	public Point getStartPoint() {
		return startPoint;
	}
	public Point getEndPoint() {
		return endPoint;
	}
	public ArrayList<HitPoint> getAllPoints() {
		return points;
	}
	public char getTag() {
		return tag;
	}
	public boolean isSunk() {
		if(hp==0) return true;
		else return false;
	}
	
}
