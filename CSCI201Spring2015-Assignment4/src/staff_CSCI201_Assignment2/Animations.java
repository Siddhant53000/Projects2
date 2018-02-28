package staff_CSCI201_Assignment2;

import javax.swing.ImageIcon;
import javax.swing.JButton;

public class Animations {
	private static int playing;
	private static final ImageIcon explosion[];
	private static final ImageIcon splash[];
	
	final public static int EXPLOSION=1,SPLASH=2,SINK=3;
	
	static{
		explosion = new ImageIcon[4];
		explosion[0] = new ImageIcon("src/explosion/expl1.png");
		explosion[1] = new ImageIcon("src/explosion/expl2.png");
		explosion[2] = new ImageIcon("src/explosion/expl3.png");
		explosion[3] = new ImageIcon("src/explosion/expl4.png");
		
		splash = new ImageIcon[7];
		splash[0] = new ImageIcon("src/splash2/splash1.png");
		splash[1] = new ImageIcon("src/splash2/splash2.png");
		splash[2] = new ImageIcon("src/splash2/splash3.png");
		splash[3] = new ImageIcon("src/splash2/splash4.png");
		splash[4] = new ImageIcon("src/splash2/splash5.png");
	}
	
	public static int numPlaying() {
		return playing;
	}
	
	public static void createAnimationWithJButton(JButton toAnimate, int animNum, ImageIcon endFrame, int duration) {
		if(animNum == EXPLOSION) {
			Animation explosionAnimation = new Animation(toAnimate, endFrame,explosion,1593, duration,true);
			Thread t = new Thread(explosionAnimation);
			t.start();
			playing++;
		}
		
		if(animNum == SPLASH) {
			Animation explosionAnimation = new Animation(toAnimate, endFrame,splash,1593,duration,true);
			Thread t = new Thread(explosionAnimation);
			t.start();
			playing++;
		}
		
		if(animNum == SINK) {
			Animation explosionAnimation = new Animation(toAnimate, endFrame,splash,1593+2300,duration,false);
			Thread t = new Thread(explosionAnimation);
			t.start();
			playing++;
		}
	}
	
	static class Animation implements Runnable{
		private final ImageIcon myAnim[];
		private final JButton toAnimate;
		private final ImageIcon endFrame;
		private final int initialDelay;
		private final int duration;
		private final boolean terminated;
		Animation(JButton toAnimate, ImageIcon endFrame, ImageIcon[] myAnim, int initialDelay, int duration,boolean terminated) {
			this.toAnimate = toAnimate;
			this.myAnim = myAnim;
			this.endFrame = endFrame;
			this.initialDelay = initialDelay;
			this.duration = duration;
			this.terminated = terminated;
		}
		@Override
		public void run() {
			try {
				Thread.sleep(initialDelay);
				for(int i = 0; i < myAnim.length; i++){
					toAnimate.setIcon(myAnim[i]);
					Thread.sleep(duration/myAnim.length);
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			toAnimate.setIcon(endFrame);
			toAnimate.setEnabled(terminated);
			playing--;
		}
		
	}
	
}
