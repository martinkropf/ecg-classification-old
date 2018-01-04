package at.ac.ait.ecg.dao;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import at.ac.ait.ecg.model.Record;
import at.ac.ait.ecg.model.Vote;

@Transactional
@Repository
public class VoteFacade extends AbstractFacade<Vote> {

	 @PersistenceContext(unitName = "entityManager")
    private EntityManager entityManager;
	 
    public VoteFacade() {
        super(Vote.class);
    }
    
 
    
    public Vote findVoteForRecordAndUser(Record record,String user)
    {
    	  Query q = entityManager.createQuery("select v from Vote v where v.user='"+user+"' and v.record.id='"+record.getId()+"'");
    	  List<Vote> results = q.getResultList();
    	  if (results.size()>0)
    		  return results.get(0);
    	  else
    		  return null;
    
    }
    
    public List<Vote> findVotesForRecord(Record record)
    {
    	  Query q = entityManager.createQuery("select v from Vote v where v.record.id='"+record.getId()+"'");
    	  List<Vote> results = q.getResultList();
   		  return results;
    
    }
    
    
}