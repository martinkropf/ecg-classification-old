<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="datatables" uri="http://github.com/dandelion/datatables" %>

<!DOCTYPE html>
<html lang="en">

  <body>  
     <div class="row">     
        <div> 
          <h3 align="center"> 
          Thanks for your vote.
          
          
          </h3>
          <br/>
              <datatables:table id="votes" data="${votes}" row="vote" theme="bootstrap3" cssClass="table table-striped">
                  
                  
                    <datatables:column title="User">
			      <c:out value="${vote.user}"></c:out>
			    </datatables:column>
		        <datatables:column title="Decision">
			              <c:out value="${vote.decision}"></c:out>			
			    </datatables:column>
   		        <datatables:column title="Comment">
			              <c:out value="${vote.comment}"></c:out>			
			    </datatables:column>
					  
			</datatables:table>      
			
    
<div class="text-center">
  <button type="button" id="normal" class="btn btn-secondary" onclick="window.location.href='${baseUrl}record/${signal}';">Modify decision</button>
  <button type="button" class="btn btn-secondary" onclick="window.location.href='${baseUrl}';">Next</button>
  
</div>
          
          

 
     </div>

 </body>
</html>