package at.ac.ait.ecg.model;

import java.util.List;


public class AvBeat {

	private List<Double> seq;
	private int nBeats;
	private List<Integer> window;
	
	public AvBeat() {
		super();
		// TODO Auto-generated constructor stub
	}

	public List<Double> getSeq() {
		return seq;
	}

	public void setSeq(List<Double> seq) {
		this.seq = seq;
	}

	public int getnBeats() {
		return nBeats;
	}

	public void setnBeats(int nBeats) {
		this.nBeats = nBeats;
	}

	public AvBeat(List<Double> seq, int nBeats) {
		super();
		this.seq = seq;
		this.nBeats = nBeats;
	}

	public List<Integer> getWindow() {
		return window;
	}

	public void setWindow(List<Integer> window) {
		this.window = window;
	}







	


	


	

}
