<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="datatables" uri="http://github.com/dandelion/datatables" %>

<!DOCTYPE html>
<html lang="en">

  <body>  
     <div class="row">     
        <div> 
          <h3 align="center"> 
          Class ${reference}
          
          
          </h3>
          </div>
          <br/>
              <datatables:table id="records" data="${records}" row="record" theme="bootstrap3" cssClass="table table-striped">
                  
                  
                    <datatables:column title="Name">
			   <a href="/ecg/record/${record.name}">  <c:out value="${record.name}"></c:out></a> 
			    </datatables:column>
		        <datatables:column title="Reference">
			              <c:out value="${record.reference}"></c:out>			
			    </datatables:column>
   		        <datatables:column title="Prediction">
			              <c:out value="${record.prediction}"></c:out>			
			    </datatables:column>
					  
			</datatables:table>      
			
    
<div class="text-center">
  <button type="button" id="normal" class="btn btn-secondary" onclick="window.location.href='${baseUrl}record/${signal}';">Modify decision</button>
  <button type="button" class="btn btn-secondary" onclick="window.location.href='${baseUrl}';">Next</button>
  
</div>
          
          

 
     </div>

 </body>
</html>