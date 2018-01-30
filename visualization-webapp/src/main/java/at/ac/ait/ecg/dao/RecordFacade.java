package at.ac.ait.ecg.dao;

import java.util.List;
import java.util.Random;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import at.ac.ait.ecg.model.Record;

@Transactional
@Repository
public class RecordFacade extends AbstractFacade<Record> {

	@PersistenceContext(unitName = "entityManager")
	private EntityManager entityManager;

	public RecordFacade() {
		super(Record.class);
	}

	public List<Record> findAllWrongPredictions() {
		Query q = entityManager.createQuery("select r from Record r where r.prediction<>r.reference");
		List<Record> results = q.getResultList();
		return results;
	}

	public Record findByFileName(String filename) {
		Query q = entityManager.createQuery("select r from Record r where r.name='" + filename + "'");
		List<Record> results = q.getResultList();
		if (results.size() > 0)
			return results.get(0);
		else
			return null;

	}

	//get record for which user has not created an annotation yet
	public List<Record> getNewRecordForUser(String username) {
		Query q = entityManager.createQuery("from Record as record where record.reference<>record.prediction AND record not in (select vote.record.id from Vote as vote where vote.user='" + username + "')");

		return q.getResultList();
	}

	//get record for which nobody has  created an annotation yet
	public List<Record> getNewRecord() {
		Query q = entityManager.createQuery("from Record as record where record.reference<>record.prediction AND record not in (select vote.record.id from Vote as vote)");
		return q.getResultList();
	}
	//get record by class from table reference
	public List<Record> findByReference(String reference) {
		Query q = entityManager.createQuery("from Record as record where record.reference='"+reference+"')");
		return q.getResultList();
	}
}