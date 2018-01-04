package at.ac.ait.ecg.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import at.ac.ait.ecg.dao.RecordFacade;
import at.ac.ait.ecg.dao.VoteFacade;
import at.ac.ait.ecg.model.AvBeat;
import at.ac.ait.ecg.model.Record;
import at.ac.ait.ecg.model.Vote;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLCell;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLStructure;

import static org.bitbucket.dollar.Dollar.*;
@Controller
public class BaseController {

	static final Logger log = LoggerFactory.getLogger(BaseController.class);

	@Autowired
	private RecordFacade recordFacade;

	@Autowired
	private VoteFacade voteFacade;
	
	@Value("${app.url}")
	String baseUrl;
	
	@Value("${result.path}")
	String resultPath;
	
	@Value("${result.extension}")
	String resultExtension;
	
	@Value("${vote.decisions}")
	String voteDecisions;

	//return random ecg for user
	@RequestMapping("/")
	public ModelAndView random() {
		List<Record> records = recordFacade.getNewRecord();
        int rnd = new Random().nextInt(records.size());
        Record record = records.get(rnd);
		ModelAndView modelAndView = getRecordData(record.getName());
		modelAndView.addObject("records", records);
		return modelAndView;
	}
	
	@RequestMapping("/record/{signal}")
	public ModelAndView specific(@PathVariable String signal) {
		List<Record> records = recordFacade.getNewRecord();

		Record record = recordFacade.findByFileName(signal);
		Vote vote = voteFacade.findVoteForRecordAndUser(record, getUser());
		ModelAndView modelAndView = getRecordData(signal);
		String comment = null;
		if (vote!=null)
			comment = vote.getComment();
		modelAndView.addObject("comment", comment);
		modelAndView.addObject("records", records);
		return modelAndView;
	}
	
	
	@RequestMapping("/browse/{reference}")
	public ModelAndView signalsByClass(@PathVariable String reference) {
		List<Record> records = recordFacade.findByReference(reference);
		ModelAndView modelAndView = new ModelAndView("browse");
		modelAndView.addObject("reference", reference);
		modelAndView.addObject("records", records);
		return modelAndView;
	}
	
	
	@RequestMapping(value="/vote",method = RequestMethod.POST)
	public ModelAndView vote(@ModelAttribute("formBean") @Valid Vote vote, BindingResult result, RedirectAttributes redirectAttrs, HttpServletRequest request)  {
		String username = getUser();
		vote.getDecision();
		System.out.println("Username: "+username +" - Record: "+ vote.getRecord().getName()+ " - Comment: "+vote.getComment()+" - Vote: "+vote.getDecision());
		Record record = recordFacade.findByFileName(vote.getRecord().getName());
		Vote theVote = voteFacade.findVoteForRecordAndUser(record, username);
		
		if (theVote==null)
		{
			theVote = new Vote();
			theVote.setDecision(vote.getDecision());
			theVote.setRecord(record);
			theVote.setUser(username);
			theVote.setComment(vote.getComment());
			theVote.setXrange(vote.getXrange());
			theVote.setYrange(vote.getYrange());
			theVote.setModifiedOn(new Date());

			voteFacade.create(theVote);
			System.out.println("Vote created");
		}
		else
		{
			theVote.setDecision(vote.getDecision());
			theVote.setRecord(record);
			theVote.setUser(username);
			theVote.setComment(vote.getComment());
			theVote.setXrange(vote.getXrange());
			theVote.setYrange(vote.getYrange());
			theVote.setModifiedOn(new Date());

			voteFacade.edit(theVote);
			System.out.println("Vote updated");
		}

//		ModelAndView modelAndView = new ModelAndView("thanks");
//		modelAndView.addObject("baseUrl", baseUrl);
//		modelAndView.addObject("signal", record.getName());
//		modelAndView.addObject("votes", voteFacade.findVotesForRecord(record));

		return random();
	}
	
	
	private ModelAndView getRecordData(String filename)
	{
		ModelAndView modelAndView = new ModelAndView("home");
		List<Double> samples = new ArrayList<Double>();
		List<Double> qrs = new ArrayList<Double>();
		List<AvBeat> avbeats = new ArrayList<AvBeat>();
		List<String> typesList = new ArrayList<String>();
		int hr1_c1 = 0;
		MatFileReader mfr;
		
		try {
			mfr = new MatFileReader(resultPath+filename+resultExtension);
			Map<String,MLArray> myMap =mfr.getContent();
			
			MLDouble ecg = (MLDouble) myMap.get("ecg");
			for (int i=0; i<ecg.getSize(); i++)
				samples.add(ecg.get(i, 0));
			
			MLDouble qrs2a = (MLDouble) myMap.get("QRS2a");
			for (int i=0; i<qrs2a.getSize(); i++)
				qrs.add(qrs2a.get(i, 0));
			
			MLStructure rhythm_res_struct = (MLStructure) myMap.get("rhythm_res");
			MLDouble hr1_c1_double = (MLDouble) rhythm_res_struct.getField("hr1_c1");
			hr1_c1 = (int) Math.round(hr1_c1_double.get(0));
			MLStructure avbeats_struct = (MLStructure) myMap.get("avbeats");
			MLCell avbeats_seq = (MLCell) avbeats_struct.getField("seq");
			MLDouble nbeats = (MLDouble) avbeats_struct.getField("nbeats");
			MLCell windowCell = (MLCell) avbeats_struct.getField("window");
			
			Map<Double,String> map = new HashMap<Double,String>();
			map.put(78.0,"N");
			map.put(65.0,"A");
			map.put(86.0,"V");
			map.put(63.0,"?");
			map.put(68.0,"D");
			map.put(69.0,"E");
			MLDouble types = (MLDouble) myMap.get("types");

			for (int i=0; i<types.getSize();i++)			
				typesList.add(map.get(types.get(i)));

			for (int i=0;i<avbeats_seq.getSize();i++)
			{
				AvBeat avbeat = new AvBeat();
				MLDouble avbeat_seq=(MLDouble) avbeats_seq.get(i);
				List<Double> values = new ArrayList<Double>();
				for (int j=0;j<avbeat_seq.getSize();j++)
				{
					values.add(avbeat_seq.get(j));
				}
				avbeat.setSeq(values);
				avbeat.setnBeats(nbeats.get(i).intValue());
				
				MLDouble windowDouble = (MLDouble) windowCell.get(i);
				int start;
				int end;
				try {
					start = windowDouble.get(0).intValue();
					end = windowDouble.get(1).intValue();
					List<Integer> window = $(start, end).toList();
					avbeat.setWindow(window);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				avbeats.add(avbeat);
			}			
			//MapUtils.debugPrint(System.out, "myMap",myMap);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Record record = recordFacade.findByFileName(filename);
		modelAndView.addObject("record", record);
		modelAndView.addObject("avbeats", avbeats);
		modelAndView.addObject("samples", samples);
		modelAndView.addObject("qrs", qrs);
		modelAndView.addObject("hr1_c1", hr1_c1);
		modelAndView.addObject("typeList", typesList);
		modelAndView.addObject("baseUrl", baseUrl);
		modelAndView.addObject("signal", filename);
		modelAndView.addObject("decisions", voteDecisions);
		return modelAndView;
	}


	private String getUser()
	{
		return SecurityContextHolder.getContext().getAuthentication().getName();
	}
}