<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>


<!DOCTYPE html>
<html lang="en">

<body>
	<div class="container">
		<div class="row">
			<div class="col-md-12 col-md-offset-0">
<!-- 				<div class="navbar" id="menu" style="display: inline; background-color: #FFFFFF">
					<ul class="nav nav-tabs" role="tablist" id="back_to_rt">
						<li><a onclick="window.location.href='https://srnportal.sharepoint.com/sites/training/RT/'"><span class="glyphicon glyphicon-home"></span>&nbsp;Radiotherapy</a></li>
					</ul>
				</div> -->
				<h1 class="margin-base-vertical">Image Management</h1>
				<br />
				<c:import url="/WEB-INF/views/tags/subject_welling.jsp" />
				<br />
				<fieldset>
					<legend>Forms</legend>
					<div class="row">
						<div class="col-sm-3">
							<div class="tile purple"
								onclick="location.href='${baseUrl}upload_info/${patient.pseudonym}';">
								<h3 class="title">Uploaded information</h3>
								<p>for LINES groups 8,9</p>
							</div>
						</div>
						<div class="col-sm-3">
							<div class="tile red"
								onclick="location.href='${baseUrl}prospective_review/${patient.pseudonym}';">
								<h3 class="title">Prospective RT review</h3>
								<p>for LINES groups 8,9</p>
							</div>
						</div>
					</div>
					<legend>Images</legend>
					<div class="row">
						<div class="col-sm-3">
							<div class="tile green"
								onclick="location.href='${baseUrl}upload/presurgical/${patient.pseudonym}';">
								<h3 class="title">Upload presurgical images</h3>
								<p>for LINES</p>
							</div>
						</div>
						<div class="col-sm-3">
							<div class="tile blue"
								onclick="location.href='${baseUrl}upload/treatmentplanning/${patient.pseudonym}';">
								<h3 class="title">Upload treatment planning images</h3>
								<p>for LINES</p>
							</div>
						</div>
						<c:if test="${fn:length(patient.images) gt 0}">
							<div class="col-sm-3">
								<div class="tile orange"
									onclick="window.open('${baseUrl}resources/cornerstone/index.html?study=${studyUID}', 'Advanced image management');">
									<h3 class="title">Advanced image management</h3>
									<p>using a web viewer</p>
								</div>
							</div>
							<div class="col-sm-3">
								<div class="tile yellow"
									onclick="location.href='${baseUrl}images/${patient.pseudonym}';">
									<h3 class="title">Edit uploaded images</h3>
									<p>in a list view</p>
								</div>
							</div>
						</c:if>
					</div>
				</fieldset>
			</div>
		</div>
	</div>
</body>
</html>