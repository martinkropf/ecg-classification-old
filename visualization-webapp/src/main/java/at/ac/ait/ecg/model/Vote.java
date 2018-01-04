package at.ac.ait.ecg.model;



import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;


@Entity
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
public class Vote extends BaseEntity {

	private static final long serialVersionUID = 1L;

	
	@Column
	private String decision;
	
	@Column
	private String user;
	
	@Column
	private String comment;
	
	@Column
	private String xrange;
	
	@Column
	private String yrange;
	
	@Column
	private Date modifiedOn;
	
    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="record_id")
	private Record record;
	
	public Vote() {
		super();
		// TODO Auto-generated constructor stub
	}



	public Vote(String decision) {
		super();
		this.decision = decision;
	}



	public String getDecision() {
		return decision;
	}



	public void setDecision(String decision) {
		this.decision = decision;
	}






	public String getUser() {
		return user;
	}



	public void setUser(String user) {
		this.user = user;
	}



	public Record getRecord() {
		return record;
	}



	public void setRecord(Record record) {
		this.record = record;
	}



	public String getComment() {
		return comment;
	}



	public void setComment(String comment) {
		this.comment = comment;
	}



	public String getXrange() {
		return xrange;
	}



	public void setXrange(String xrange) {
		this.xrange = xrange;
	}



	public String getYrange() {
		return yrange;
	}



	public void setYrange(String yrange) {
		this.yrange = yrange;
	}



	public Date getModifiedOn() {
		return modifiedOn;
	}



	public void setModifiedOn(Date modifiedOn) {
		this.modifiedOn = modifiedOn;
	}


	


	


	

}
