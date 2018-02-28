package staff_CSCI201_Assignment2;

import java.awt.Point;
import java.awt.event.ActionListener;

public abstract class GridButtonListener implements ActionListener{
	private Point location;
	protected GridButtonListener(Point location) {
		this.location = location;
	}
	public Point getLocation() {
		return location;
	}
}