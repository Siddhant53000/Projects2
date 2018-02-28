package staff_CSCI201_Assignment2;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Random;

public class Utils {
	static Random rand;
	static{
		rand = new Random();
	}
	public static int randInt(int min, int max) {
	    int randomNum = rand.nextInt((max - min) + 1) + min;
	    return randomNum;
	}
	public static String readFile(String path, Charset encoding) {
		byte[] encoded;
		String toReturn = null;
		try {
			encoded = Files.readAllBytes(Paths.get(path));
			toReturn = new String(encoded, encoding);
		} catch (IOException e) {
			System.out.println("ERROR READING FILE:"+path);
		}
		return toReturn;
	}
}
