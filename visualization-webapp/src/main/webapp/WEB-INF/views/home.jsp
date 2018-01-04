<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="datatables" uri="http://github.com/dandelion/datatables" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html>
<html lang="en">

  <body>  
     <div class="row">     
        <div> 
          <h3> 
             ${signal}
          </h3>
		<p> 
             
             
              Reference: ${record.reference}
              <br/>
              Prediction: ${record.prediction}
              <br/>
             Heart Rate: ${hr1_c1}
             <br/>
			${fn:length(records)} left
          </p>
  <div id="selection-div"></div>
  <div id="bci-div"></div>

 <div id="plotly-div"></div>
 
      <script>
      var selectorOptions = {
    		    buttons: [{
    		        step: 'second',
    		        stepmode: 'backward',
    		        count: 1,
    		        label: '1y'
    		    }, {
    		        step: 'second',
    		        stepmode: 'backward',
    		        count: 6,
    		        label: '6m'
    		    },  {
    		        step: 'all',
    		    }],
    		};
      
      
      var tmp =  "${typeList}";
     
      tmp =tmp.slice(1, -1);
      tmp=tmp.split(",");
      
      samples= ${samples};
      qrs= ${qrs};
	  annotations=[];
      var N = samples.length; 
      range=Array.apply(null, {length: N}).map(Number.call, Number);
      fs=300;
      dt=1/fs;
      var size = N/fs;
      range=range.map(function(x) { return x * dt; });
      qrs=qrs.map(function(x) { return x * dt; });
      for (i=0; i<qrs.length;i++)
   	  {
   	   // console.log(i);
   	    
   	    annotation={
                x: qrs[i],
                y: 1,
                xref: 'x',
                yref: 'y',
                text: tmp[i],
                showarrow: true,
                arrowhead: 2,
                opacity: 0.8,
                ax: 0,
                ay: -18
              };
   	    annotations.push(annotation);
   	  }
      //alert(annotations);
      
      

 			
 			

      trace1 = {
			
	  		  x: range, 
			  y: samples,
    		  name: 'ECG', 
    		  type: 'scatter', 
    		  uid: '73ddbd'
    		};
      
      
		//BCI
		diff=[];
		//alert(qrs);
		for (var i=0; i<qrs.length; i++) {
			
				var previous=qrs[i-1];
		
			
			var current=qrs[i];
			
			
			diff.push(60/(current - previous));
		
			var next=qrs[i+1];

			}
			//alert(diff);
		//	alert(qrs.length);
	trace2 = {
			
	  		  x: qrs, 
			  y: diff,
			  yaxis: 'y2',
    		  name: 'HR', 
    		  mode: 'markers', 
    		  uid: '73ddbd'
    		};
    		data = [trace1,trace2];
    		layout = {
    		  autosize: true, 
    		  bargap: 0.2, 
    		  bargroupgap: 0, 
    		  barmode: 'group', 
    		  boxgap: 0.3, 
    		  boxgroupgap: 0.3, 
    		  boxmode: 'overlay', 
    		  dragmode: 'zoom', 
    		  font: {
    		    color: '#444', 
    		    family: '', 
    		    size: 12
    		  }, 
    		  height: 365, 
    		  hidesources: true, 
    		  hovermode: 'x', 
    		  legend: {
    		    x: 1.02, 
    		    y: 1, 
    		    bgcolor: '#fff', 
    		    bordercolor: '#444', 
    		    borderwidth: 0, 
    		    font: {
    		      color: '', 
    		      family: '', 
    		      size: 0
    		    }, 
    		    traceorder: 'normal', 
    		    xanchor: 'left', 
    		    yanchor: 'top'
    		  }, 
    		  margin: {
    		    r: 80, 
    		    t: 10, 
    		    autoexpand: true, 
    		    b: 0, 
    		    l: 30, 
    		    pad: 0
    		  }, 
    		  paper_bgcolor: '#fff', 
    		  plot_bgcolor: '#fff', 
    		  separators: '.,', 
    		  showlegend: false,    		
    		  annotations: annotations,
    		  smith: false, 
    		  title: '${filename}', 
    		  titlefont: {
    		    color: '', 
    		    family: '', 
    		    size: 0
    		  }, 
    		  width: 1214, 
    		  xaxis: {
    		    anchor: 'y', 
    		    autorange: true, 
    		    autotick: false, 
    		    domain: [0, 1], 
    		    dtick: 0.2, 
    		    exponentformat: 'B', 
    		    gridcolor: '#ff9c9c', 
    		    gridwidth: 1, 
    		    minorgridcount: 0.1,
    		    minorgridwidth: 1,
    		    minorgridcolor: "#eee",
    		    linecolor: '#444', 
    		    linewidth: 1, 
    		    mirror: false, 
    		    nticks: 1, 
    		    overlaying: false, 
    		    position: 0, 
    		    range: [0,size], 
    		    rangemode: 'normal', 
    		    rangeselector: selectorOptions,
    		      rangeslider: {range: [0, size]},
    		                          
    		    showexponent: 'all', 
    		    showgrid: false, 
    		    showline: true, 
    		    showticklabels: true, 
    		    tick0: 0, 
    		    tickangle: 'auto', 
    		    tickcolor: '#444', 
    		    tickfont: {
    		      color: '', 
    		      family: '', 
    		      size: 0
    		    }, 
    		    ticklen: 5, 
    		    ticks: '', 
    		    tickwidth: 1, 
    		    titlefont: {
    		      color: '', 
    		      family: '', 
    		      size: 0
    		    }, 
    		    type: 'linear', 
    		    zeroline: true, 
    		    zerolinecolor: '#444', 
    		    zerolinewidth: 1
    		  }, 
    		  yaxis: {
    		    anchor: 'x', 
    		    autorange: true, 
    		    autotick: true, 
    		    domain: [0, 0.8], 
    		    dtick: 0.25, 
    		    exponentformat: 'B', 
    		    gridcolor: '#ff9c9c', 
    		    gridwidth: 1, 
    		    linecolor: '#444', 
    		    linewidth: 2, 
    		    mirror: false, 
    		    nticks: 0, 
    		    overlaying: false, 
                fixedrange: false,
                minorgridcount: 0.1,
    		    minorgridwidth: 1,
    		    minorgridcolor: "#eee",
    		    position: 0, 
    		    range: [-0.5,0.5], 
    		    rangemode: 'normal', 
    		    showexponent: 'all', 
    		    showgrid: false, 
    		    showline: false, 
    		    showticklabels: true, 
    		    tick0: 0, 
    		    tickangle: 'auto', 
    		    tickcolor: '#444', 
    		    tickfont: {
    		      color: '', 
    		      family: '', 
    		      size: 0
    		    }, 
    		    ticklen: 8, 
    		    ticks: '', 
    		    tickwidth: 1, 
    		    title: 'Click to enter Y axis title', 
    		    titlefont: {
    		      color: '', 
    		      family: '', 
    		      size: 0
    		    }, 
    		    type: 'linear', 
    		    zeroline: true, 
    		    zerolinecolor: '#444', 
    		    zerolinewidth: 1
    		  },
    		   yaxis2: {domain: [0.8, 1]},
    		};
    		Plotly.plot('plotly-div', {
    		  data: data,
    		  layout: layout
    		});
 
    		var myDiv = document.getElementById('plotly-div');
    
 			
      </script>
      
      
      
      <c:forEach items="${avbeats}" var="entry" varStatus="loop">
      <script>
   			var seq=${entry.seq};
   			
   			//var x=Array.apply(null, {length: seq.length}).map(Number.call, Number);
   			var x=${entry.window};
   			
   			var x2=[];
   			for (entry in x)
			{
				x2.push((x[entry]/300));
			}
   			

       		var trace1 = {
 				  x: x2,
 				  y: seq,
 				  type: 'scatter'
 				};

   			var data = [trace1];
 		    $( "#plotly-div" ).append( "<div class=\"col-sm-4\" id=\"avbeat_div_${loop.index}\">");
 		    
 		   
 		    var beats = ${entry.nBeats};
 		    var ratio = Number((beats / qrs.length *100 ).toFixed(1)); // 6.7

 		   var layout = {
 				  title:'Class ${loop.index+1}: '+ratio+'% (${entry.nBeats}/'+qrs.length+')',
 				  height: 300, 
 				  width: 385
 				};
 		   
 		    
 		    
 		   var loop=${loop.index};
 		   if (loop<999)
 			   Plotly.newPlot('avbeat_div_${loop.index}', data,layout);
 		
 		   var avbeat_div=document.getElementById('avbeat_div_${loop.index}');
 		  avbeat_div.on('plotly_selected', function(eventData) {
 		         xrange.value=eventData.range.x; 
 			alert(eventData.range.y);
 			 console.log(eventData.range.x);
 			 console.log(eventData.range.y);
 			 var start =  Number((eventData.range.x[0]).toFixed(2)); 
 			 var end =  Number((eventData.range.x[1]).toFixed(2)); 
 			 var diff = Number((end-start).toFixed(2));
 			 
 			 //selection_div.innerHTML= + start + ' - '+ end + ' ('+diff+')';

 			
 		});
 			
 			
 			</script>
</c:forEach>




<!-- 
          <datatables:table id="patients" data="${patients}" row="patient" theme="bootstrap3" cssClass="table table-striped">
                  
                  
                    <datatables:column title="Patient ID">
			      <c:out value="${patient.pseudonym}"></c:out>
			    </datatables:column>
		        <datatables:column title="Date of birth">
			              <c:out value="${patient.birthdate}"></c:out>			
			    </datatables:column>
   		        <datatables:column title="Gender">
			              <c:out value="${patient.gender}"></c:out>			
			    </datatables:column>
			    <datatables:column title="Enrolled DCP">
			              <c:out value="${patient.dcp}"></c:out>			
			    </datatables:column>			    
			        
			    <datatables:column title="Registered by">
			              <c:out value="${patient.createdBy}"></c:out>			
			    </datatables:column>
			    
   			    <datatables:column title="Center">
			              <c:out value="${patient.center}"></c:out>			
			    </datatables:column>
			   <datatables:column title="Action">
			    <a href="${patient.pseudonym}">    <c:out value="Image Management"></c:out></a>
			    </datatables:column>
			  
			</datatables:table>      
			    -->
        </div> 
       
     </div>
<div class="text-center">
<form:form action="${baseUrl}vote" method="post" modelAttribute="formBean" class="form-horizontal" role="form">
<div class="container">

        <c:import url="${decisions}"/> 

 </div>

        
   <p>
   
<br/>
 <br/>

     <label for="comment">Comment</label>
     <input type="text" id="comment" value="${comment}" name="comment"  />

  
  
  
  <br/>
   
  <input type="hidden" id="record" name="record" value="${signal}" />
   
  <input type="hidden" id="decision" name="decision"/>
    <input type="hidden" id="xrange" name="xrange"/>
    <input type="hidden" id="yrange" name="yrange"/>
  
  </form:form>
  
  <script>
	var xrange = document.getElementById('xrange');
	var yrange = document.getElementById('yrange');
	var selection_div = document.getElementById('selection-div');

	myDiv.on('plotly_selected', function(eventData) {
	         xrange.value=eventData.range.x; 
		 yrange.value=eventData.range.y;
		 console.log(eventData.range.x);
		 console.log(eventData.range.y);
		 var start =  Number((eventData.range.x[0]).toFixed(2)); 
		 var end =  Number((eventData.range.x[1]).toFixed(2)); 
		 var diff = Number((end-start).toFixed(2));
		 
		 selection_div.innerHTML= + start + ' - '+ end + ' ('+diff+')';

		
	});
	
  </script>
</div>

 </body>
</html>