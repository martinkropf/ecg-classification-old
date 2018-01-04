<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="datatables"
	uri="http://github.com/dandelion/datatables"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s"%>

<!DOCTYPE html>
<html lang="en">

<body>

									<c:import url="/WEB-INF/views/tags/subject_welling.jsp"/> 

<br/>


	<!-- Page Content -->
	<c:if test="${not empty message}">
		<div class="alert alert-success">
			<a href="#" class="close" data-dismiss="alert">&times;</a> <strong>Success!</strong>
			${message}
		</div>
	</c:if>

						
	<hr>


	<datatables:table id="images" data="${images}" row="image"
		theme="bootstrap3" cssClass="table table-striped">
		<datatables:column title="Thumbnail">
					 <img class="img-responsive"
								style="width: 200px"
								src="http://localhost:8080/im-showcase/jpeg/${image.oid}" />
						
		</datatables:column>

		<datatables:column title="Comment">
			<c:out value="${image.comment}"></c:out>
		</datatables:column>

		<datatables:column title="Type">
			<c:out value="${image.imageType.imageType}"></c:out>
		</datatables:column>

		<datatables:column title="Subtype">
			<c:out value="${image.presurgicalType.presurgicalType}"></c:out>
			<c:out value="${image.planningType.planningType}"></c:out>
		</datatables:column>

		<datatables:column title="Action">
			<a href="#" onclick="alert('To be done...')">Edit</a>

			<a href="http://localhost:8080/im-showcase/images/delete/${image.oid}" >Delete</a>
		</datatables:column>
	</datatables:table>
	
	
	
	<hr>
						<button onclick="window.location.href='${baseUrl}${patient.pseudonym}';" class="btn">Back</button>
	
	<!-- 
	<h1>Upload files</h1>
	<div style="width: 500px; padding: 20px">

		<input id="fileupload" type="file" name="files[]"
			data-url="/im-showcase/controller/upload" multiple>
		<hr>

		<div id="dropzone" class="fade well">Drop files here</div>
		<hr>

		<div id="progress" class="progress">
			<div class="bar" style="width: 0%;"></div>
		</div>
		<hr>
		<form:form>
			<table id="uploaded-files" class="table">
				<tr>
					<th>File Name</th>
					<th>File Size</th>
					<th>Content Type</th>
					<th>Image Type</th>
					<th>Comment</th>
				</tr>
			</table>
			<p>
				<button type="submit" class="btn btn-primary">Submit</button>
			</p>
		</form:form>
	</div>
	 -->

  

</body>
</html>