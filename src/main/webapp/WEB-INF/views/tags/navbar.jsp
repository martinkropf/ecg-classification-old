<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<div class="navbar navbar-inverse navbar-fixed-top">
  <div class="container">
    <div class="navbar-header">                                   
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="#">ECG Viewer</a>
        </div>
        <div class="navbar-collapse collapse">  
          <ul class="nav navbar-nav">
           <li class="active"><a href="<c:url value="/" />"><sec:authentication property="name"/></a></li>
        
           <sec:authorize access="hasAnyRole('ROLE_ADMIN')">
       		<li><a href="<c:url value="/browse/N" />">Normal</a></li>
       		<li><a href="<c:url value="/browse/A" />">AF</a></li>
       		<li><a href="<c:url value="/browse/O" />">Other</a></li>
       		<li><a href="<c:url value="/browse/~" />">Noise</a></li>
			</sec:authorize>

       		<!-- 
            <li><a href="<c:url value="/form" />">Forms</a></li>
            <li><a href="<c:url value="/fileupload" />">File Upload</a></li>
            <li><a href="<c:url value="/misc" />">Misc</a></li> -->
          </ul>
        </div>   			      		 
  </div>
</div>