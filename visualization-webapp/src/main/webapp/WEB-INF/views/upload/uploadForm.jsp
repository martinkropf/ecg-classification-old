<%@page contentType="text/html;charset=UTF-8"%>
<%@page pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
<head>
<META http-equiv="Content-Type" content="text/html;charset=UTF-8">
<title>File upload</title>
</head>
<body>
	<form:form modelAttribute="uploadItem" method="post" id="form" enctype="multipart/form-data">
		<fieldset>
			<c:import url="/WEB-INF/views/tags/subject_welling.jsp" />
		</fieldset>
		<hr />
		<c:import url="/WEB-INF/views/tags/messages.jsp" />
		
		<fieldset>
			<p>
				<form:label for="name" path="comment">Comment</form:label>
				<br />
				<form:input class="form-control" path="comment" />
			</p>
			<p>
				<form:label for="name" path="imageType">Type</form:label>
				<br />
				<c:choose>
					<c:when test="${uploadItem.imageType == 'treatmentplanning'}">
						<form:select class="form-control" path="planningType">
							<form:option class="form-control" value="treatment_plan">Treatment plan</form:option>
							<form:option class="form-control" value="fields_and_beam_modification">Fields and beam modification</form:option>
							<form:option class="form-control" value="dose_volume_histogram">Dose Volume Histogram</form:option>
							<form:option class="form-control" value="other">other</form:option>
						</form:select>
					</c:when>
					<c:when test="${uploadItem.imageType == 'presurgical'}">
						<form:select class="form-control" path="presurgicalType">
							<form:option class="form-control" value="mri">MRI</form:option>
							<form:option class="form-control" value="ct">CT</form:option>
							<form:option class="form-control" value="other">other</form:option>
						</form:select>
					</c:when>
				</c:choose>
			</p>
			<p>
				<form:label for="fileData" path="fileData">File</form:label>
				<br />
				<form:input path="fileData" type="file" />
			</p>
			<p>
				<button
					onclick="document.getElementById('form').action='${baseUrl}upload_info/${uploadItem.patient.pseudonym}';document.getElementById('form').method='get';"
					class="btn">Cancel</button>
				<button type="submit" id="uploadButton" class="btn btn-primary">Submit</button>
			</p>
		</fieldset>
	</form:form>
</body>
</html>