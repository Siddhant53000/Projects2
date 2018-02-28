package staff_CSCI201_Assignment2;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridLayout;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import javax.imageio.ImageIO;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.KeyStroke;
import javax.swing.border.EmptyBorder;
import javax.swing.filechooser.FileNameExtensionFilter;

public class BattleshipFrame extends JFrame{

	private static final long serialVersionUID = 1L;
	private final StartPanel startPanel;
	//private final JLabel gameLog;
	
	private final JLabel playerName;
	private final BattleshipGrid playerGrid;
	
	private final JLabel opponentName;
	private final BattleshipGrid opponentGrid;
	
	private final static int SPACING = 10;
	
	private int readyCount = 0;
	
	private BattleTimer bTimer;
	private GameManager gameManager;
	private Thread managerThread;
	
	public BattleshipFrame() {
		super("Battleship");
		JPanel mainPanel = new JPanel(new BorderLayout());
		mainPanel.setBackground(Color.WHITE);
		
		playerName = new JLabel("Player1");
		opponentName = new JLabel("Player2");
		bTimer = new BattleTimer();
		
		mainPanel.add(new NamePanel(playerName,opponentName,bTimer),BorderLayout.NORTH);
		
		JPanel gridPanel = new JPanel();
		gridPanel.setLayout(new BoxLayout(gridPanel, BoxLayout.X_AXIS));
		
		playerGrid = new BattleshipGrid();
		for(int i = 0; i < 10; i++) {
			for(int j = 0; j < 10; j++) {
				playerGrid.addListenerToGridSpace(new GridButtonEditListener(new Point(j,i)));
			}
		}
		playerGrid.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		playerGrid.setBackground(Color.YELLOW);
		gridPanel.add(playerGrid);
		
		gridPanel.add(Box.createHorizontalStrut(SPACING));
		
		opponentGrid = new BattleshipGrid();
		for(int i = 0; i < 10; i++) {
			for(int j = 0; j < 10; j++) {
				opponentGrid.addListenerToGridSpace(new GridButtonAttackListener(new Point(j,i)));
			}
		}
		opponentGrid.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		opponentGrid.setBackground(Color.YELLOW);
		gridPanel.add(opponentGrid);
		mainPanel.add(gridPanel);
		
		gameManager = new GameManager(bTimer, playerGrid, opponentGrid,this);
		
		JPanel infoPanel = new JPanel(new GridLayout(0,2));
		/*gameLog = new JLabel() {
			private static final long serialVersionUID = 1L;

			public void setText(String text) {
				super.setText("Log: "+text);
			}
		};*/
		infoPanel.add(gameManager);
		infoPanel.setBackground(Color.WHITE);
		infoPanel.setBorder(new EmptyBorder(10,10,10,10));
		
		startPanel = new StartPanel(opponentGrid);
		infoPanel.add(startPanel);
		infoPanel.setBorder(new EmptyBorder(SPACING,0,0,0));
		mainPanel.add(infoPanel,BorderLayout.SOUTH);
		
		mainPanel.setBorder(new EmptyBorder(SPACING,SPACING,SPACING,SPACING));
		
		add(mainPanel);
		setSize(640,480);
		
		setJMenuBar(makeMenu());
		
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLocationRelativeTo(null);
		setVisible(true);
	}
	
	private JMenuBar makeMenu() {
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);
		JMenu help = new JMenu("Info");
		help.setMnemonic('I');
		menuBar.add(help);
		
		JMenuItem rules = new JMenuItem("How To");
		rules.setMnemonic('H');
		rules.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_H,ActionEvent.CTRL_MASK));
		rules.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent ae) {
				JDialog jd = new JDialog();
				jd.setTitle("Battleship Instructions");
				jd.setSize(360,250);
				jd.setLocationRelativeTo(null);
				jd.setResizable(false);
				JTextArea jta = new JTextArea();
				jta.setEditable(false);
				jta.setText(Utils.readFile("ReadMe.txt", StandardCharsets.UTF_8));
				
				JScrollPane jsp = new JScrollPane(jta);
				jd.add(jsp);
				jd.setVisible(true);
			}
		});
		
		JMenuItem about = new JMenuItem("About");
		about.setMnemonic('A');
		about.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_A,ActionEvent.CTRL_MASK));
		about.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent ae) {
				JDialog jd = new JDialog();
				jd.setTitle("About");
				jd.setSize(360,250);
				jd.setLayout(new BorderLayout());
				
				Box topBox = Box.createHorizontalBox();
				topBox.add(Box.createHorizontalGlue());
				topBox.add(new JLabel("Made by Matt Carey"));
				topBox.add(Box.createHorizontalGlue());
				jd.add(topBox,BorderLayout.NORTH);
				
				BufferedImage img = null;
				try {
					img = ImageIO.read(new File("src/face.jpg"));
				} catch (IOException e) {}
				jd.add(new JLabel(new ImageIcon(img)));
				
				Box bottomBox = Box.createHorizontalBox();
				bottomBox.add(Box.createHorizontalGlue());
				bottomBox.add(new JLabel("CSCI201 USC: Assignment 4"));
				bottomBox.add(Box.createHorizontalGlue());
				jd.add(bottomBox,BorderLayout.SOUTH);
				
				jd.setLocationRelativeTo(null);
				jd.setResizable(false);
				jd.setVisible(true);
			}
		});
		
		help.add(rules);
		help.add(about);
		return menuBar;
	}
	
	private class GridButtonEditListener extends GridButtonListener {
		public GridButtonEditListener(Point location) {
			super(location);
		}
		@Override
		public void actionPerformed(ActionEvent e) {
			if(playerGrid.isOccupied(this.getLocation())) {
				playerGrid.clearShipAt(this.getLocation());
				readyCheck(false); // we are less ready
			} else if(playerGrid.getShipCount() != 5) {
				new GameEditWindow(playerGrid,getLocation());
			}
		}
	}
	
	private class GridButtonAttackListener extends GridButtonListener {
		public GridButtonAttackListener(Point location) {
			super(location);
		}
		@Override
		public void actionPerformed(ActionEvent e) {
			if(!gameManager.playerCanMove()) return;
			if(opponentGrid.hitShips(getLocation(),true,gameManager)){	
				//gameLog.setText("Player:"+BattleshipGrid.pointToCoord(getLocation())+" Computer:"+BattleshipGrid.pointToCoord(p));
			}
		}
	}
	
	public void enterEditMode() {
		opponentGrid.clearGrid();
		playerGrid.clearGrid();
		startPanel.reset();
		startPanel.setVisible(true);
		startPanel.startEnabled(false);
		opponentGrid.enableGrid(false);
		playerGrid.enableGrid(true);
		readyCount = 0;
		gameManager.logNewInfo("You are in edit mode, click to place your ships.");
		//gameLog.setText("You are in edit mode, click to place your ships.");
		gameManager.endGame();
	}
	
	public void enterGameMode() {
		startPanel.setVisible(false);
		opponentGrid.enableGrid(true);
		playerGrid.enableGrid(false);
		//gameLog.setText("Player:N/A Computer:N/A");
		managerThread = new Thread(gameManager);
		managerThread.start();
	}
	
	private void readyCheck(boolean ready) {
		if(ready)readyCount++;
		else readyCount--;
		if(readyCount < 6) {
			this.startPanel.startEnabled(false);
		} else {
			this.startPanel.startEnabled(true);
		}
	}
	
	class GameEditWindow extends JDialog {
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		JPanel topPanel;
		JComboBox<String> shipSelect;
		JPanel midPanel;
		JRadioButton[] directions;
		JButton placeShip;
		Point location;
		BattleshipGrid editGrid;
		JDialog currentSelf;
		
		GameEditWindow(BattleshipGrid gridToEdit, Point locationToEdit) {
			location = locationToEdit;
			editGrid = gridToEdit;
			currentSelf = this;
			setModal(true);
			setSize(300,200);
			setTitle(String.valueOf((char)(location.y+'A'))+String.valueOf(location.x+1));
			setLocationRelativeTo(null);
			
			topPanel = new JPanel();
			JLabel select = new JLabel("Select Ship:");
			topPanel.add(select);
			shipSelect = new JComboBox<String>();
			topPanel.add(shipSelect);
			
			ButtonGroup buttongrp = new ButtonGroup();
			midPanel = new JPanel();
			JPanel topmid = new JPanel();
			JPanel botmid = new JPanel();
			directions = new JRadioButton[4];
			directions[0] = new JRadioButton("North");
			directions[1] = new JRadioButton("South");
			directions[2] = new JRadioButton("East");
			directions[3] = new JRadioButton("West");
			directions[0].setSelected(true);
			for(JRadioButton jrb : directions) {
				buttongrp.add(jrb);
			}
			topmid.add(directions[0]);
			topmid.add(directions[1]);
			botmid.add(directions[2]);
			botmid.add(directions[3]);
			midPanel.setLayout(new BoxLayout(midPanel,BoxLayout.Y_AXIS));
			midPanel.add(Box.createGlue());
			midPanel.add(topmid);
			midPanel.add(botmid);
			midPanel.add(Box.createGlue());
			
			placeShip = new JButton("Place Ship");
			placeShip.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent ae) {
					int size = 0;
					char tag = 'E';//error, this will never occur
					if(shipSelect.getSelectedItem().equals("Aircraft Carrier")) {
						size = 4;//we add 4 to the head
						tag = 'A';
					} else if(shipSelect.getSelectedItem().equals("Battleship")) {
						size = 3;//we add 3 to the head
						tag = 'B';
					} else if(shipSelect.getSelectedItem().equals("Cruiser")) {
						size = 2;//...
						tag = 'C';
					} else if(shipSelect.getSelectedItem().equals("Destroyer")) {
						size = 1;//...
						tag = 'D';
					}
					Point endLocation = new Point();
					endLocation.setLocation(location);
					if(directions[0].isSelected()) endLocation.y -= size;
					else if(directions[1].isSelected()) endLocation.y += size;
					else if(directions[2].isSelected()) endLocation.x += size;
					else if(directions[3].isSelected()) endLocation.x -= size;
					boolean validPos = editGrid.addShip(new Battleship(tag,location,endLocation));
					if(validPos) {
						currentSelf.setModal(false);
						currentSelf.setVisible(false);
						readyCheck(true); //another ship is valid!
					}
				}
			});
			
			int a = 0,b = 0,c = 0,d = 0;
			for( Battleship ship :editGrid.getListOfShips()) {
				if(ship.getTag() == 'A') a++;
				if(ship.getTag() == 'B') b++;
				if(ship.getTag() == 'C') c++;
				if(ship.getTag() == 'D') d++;
			}
			shipSelect.removeAllItems();
			if(a != 1) shipSelect.addItem("Aircraft Carrier");
			if(b != 1) shipSelect.addItem("Battleship");
			if(c != 1) shipSelect.addItem("Cruiser");
			if(d != 2) shipSelect.addItem("Destroyer");
			add(topPanel,BorderLayout.NORTH);
			add(midPanel);
			add(placeShip,BorderLayout.SOUTH);
			
			setVisible(true);
			setAlwaysOnTop(true);
		}
	}

	class StartPanel extends JPanel {
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		private final JButton startButton;
		private final JButton fileButton;
		private final JLabel fileLabel;
		private final JFileChooser fileChooser;
		private File selectedFile;
		
		StartPanel(final BattleshipGrid toPopulateWithFile) {
			setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
			
			fileChooser = new JFileChooser();
			fileChooser.setAcceptAllFileFilterUsed(false);
			fileChooser.addChoosableFileFilter(new FileNameExtensionFilter("Battle files", "battle"));
			fileChooser.setCurrentDirectory(new File("src/"));
			startButton = new JButton("START");
			startButton.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent ae) {
					enterGameMode();
				}
			});
			fileButton = new JButton("Select File...");
			fileButton.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent ae) {
					int returnVal = fileChooser.showOpenDialog(null);
			        if (returnVal == JFileChooser.APPROVE_OPTION) {
			        	boolean wasNull = (selectedFile == null);
			        	selectedFile = fileChooser.getSelectedFile();
			        	if(toPopulateWithFile.loadMap(selectedFile)){
			        		fileLabel.setText(selectedFile.getName().split("\\.")[0]);
			        		if(wasNull && selectedFile!=null){
			        			readyCheck(true);
			        		}
			        	} else{
			        		if(!wasNull && selectedFile==null){
			        			readyCheck(false);
			        		}
			        		selectedFile = null;
			        		fileLabel.setText("Invalid!!!");
			        	}
			        }
				}
			});
			fileLabel = new JLabel() {

				private static final long serialVersionUID = 1L;

				public void setText(String text) {
					super.setText("File: "+ text);
				}
			};
			
			
			add(fileButton);
			add(Box.createHorizontalStrut(5));
			add(fileLabel);
			add(Box.createHorizontalGlue());
			add(startButton);
			add(Box.createHorizontalStrut(20));
			
			setBackground(Color.WHITE);
			setBorder(new EmptyBorder(10,10,10,10));
		}
		
		public void reset() {
			startEnabled(false);
			selectedFile = null;
			fileLabel.setText("...");
		}

		public void startEnabled(boolean b) {
			startButton.setEnabled(b);
		}
		
		public File getSelectedFile() {
			return selectedFile;
		}
	}

	class NamePanel extends JPanel {
		private static final long serialVersionUID = 1L;

		NamePanel(JLabel playerName, JLabel opponentName, BattleTimer timerText) {
			
			setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
			add(Box.createHorizontalGlue());
			add(playerName);
			add(Box.createHorizontalGlue());
			add(timerText);
			add(Box.createHorizontalGlue());
			add(opponentName);
			add(Box.createHorizontalGlue());
			setBackground(Color.WHITE);
			setBorder(new EmptyBorder(10,10,10,10));
		}
	}
	
}
