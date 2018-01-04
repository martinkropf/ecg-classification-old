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
             
              <br/>
              Reference: ${record.reference}
              <br/>
              Prediction: ${record.prediction}
              <br/>
               ${fn:length(records)} left
          </p>
          



 <div id="chartContainer" style="height: 370px; width: 100%;">
</div>

<div class="text-center">
<form:form action="${baseUrl}vote" method="post" modelAttribute="formBean" class="form-horizontal" role="form">
  <button type="button" onclick="document.getElementById('decision').value='N';document.forms[0].submit();" class="btn btn-secondary">Normal</button>
  <button type="button" onclick="document.getElementById('decision').value='A';document.forms[0].submit();"  class="btn btn-secondary">AF</button>
  <button type="button" onclick="document.getElementById('decision').value='O';document.forms[0].submit();"  class="btn btn-secondary">Other</button>
  <button type="button" onclick="document.getElementById('decision').value='P';document.forms[0].submit();"  class="btn btn-secondary">Noise</button>
   <p>
   
<br/>
 <br/>

     <label for="comment">Comment</label>
     <input type="text" id="comment" value="${comment}" name="comment"  />

  
  
  
  <br/>
   
  <input type="hidden" id="record" name="record" value="${signal}" />
   
  <input type="hidden" id="decision" name="decision"/>
  </form:form>
</div>


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

 </body>
</html>