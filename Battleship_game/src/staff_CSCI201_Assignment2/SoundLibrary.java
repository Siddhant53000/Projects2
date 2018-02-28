package staff_CSCI201_Assignment2;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.sound.sampled.*;


public class SoundLibrary {
	private static Map<String, File> soundMap;
	static{
		soundMap = new HashMap<String,File>();
		soundMap.put("cannon.wav", new File("src/Sounds/cannon.wav"));
		soundMap.put("explode.wav", new File("src/Sounds/explode.wav"));
		soundMap.put("sinking.wav", new File("src/Sounds/sinking.wav"));
		soundMap.put("splash.wav", new File("src/Sounds/splash.wav"));
	}
	
	public static void playSoundAfterDelay(String sound,int ms) {
		Thread t = new Thread(new SoundPlayer(sound,ms));
		t.start();
	}
	
	static class SoundPlayer implements Runnable{
		String soundToPlay;
		int delay;
		SoundPlayer(String toPlay,int delay) {
			soundToPlay = toPlay;
			this.delay = delay;
		}
		@Override
		public void run() {
			try {
				Thread.sleep(delay);
				playSound(soundToPlay);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	private static void playSound(String sound) {
		File toPlay = soundMap.get(sound);
		if(toPlay == null) {
			toPlay = new File(sound);
			soundMap.put(sound, toPlay);
		}
		
		try {
		AudioInputStream stream = AudioSystem.getAudioInputStream(toPlay);
		AudioFormat format = stream.getFormat();
		SourceDataLine.Info info = new DataLine.Info(SourceDataLine.class,format,(int) (stream.getFrameLength() * format.getFrameSize()));
		SourceDataLine line = (SourceDataLine) AudioSystem.getLine(info);
		
		//long frames = stream.getFrameLength();
		//System.out.println((frames+0.0)/format.getFrameRate());
		
		line.open(stream.getFormat());
		line.start();
		int num_read = 0;
		byte[] buf = new byte[line.getBufferSize()];
		while ((num_read = stream.read(buf, 0, buf.length)) >= 0)
		{
			int offset = 0;
			
			while (offset < num_read)
			{
				offset += line.write(buf, offset, num_read - offset);
			}
		}
		line.drain();
		line.stop();
		} catch(IOException | UnsupportedAudioFileException | LineUnavailableException ioe) {
			System.out.println("Audio file is invalid!");
		}
	}
}
