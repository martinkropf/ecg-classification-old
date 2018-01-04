<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ page session="true"%>
<html>
<body>
	<c:import url="/WEB-INF/views/tags/tabbar.jsp" />
	<div id="formsContent">
		<h2>Uploaded information for LINES groups 8,9</h2>
		<form class="form-horizontal" role="form"></form>
		<form:form id="form" action="http://im-staging.ehealth-systems.at/im-showcase/upload_info" method="post" modelAttribute="formBean"
			class="form-horizontal" role="form">
			<br />
			<c:import url="/WEB-INF/views/tags/subject_welling.jsp" />
			<script type="text/javascript">
				$("#form-image-tab a")
						.click(
								function(e) {
									e.preventDefault();
									$(this).tab('show');
									if (current_img_inst_uid == null && $(this).context.innerHTML == 'Image') {
										document.getElementById('iframe').src = '${dwvUrl}index.html?input=${baseUrl}raw%2F${presurgical_images[0].oid}';
										current_img_inst_uid = '${presurgical_images[0].oid}';
									}
								});
			</script>
			<!-- <br/>  -->
			<div class="tab-content">
				<div class="tab-pane active" id="form-tab">
			<c:import url="/WEB-INF/views/tags/messages.jsp" />
					<fieldset>
						<legend>Post-chemotherapy, pre-surgery images</legend>
						<div class="form-group">
							<script>
								var current_img_inst_uid = null;
								function swich_tab_by_thumbnail(img_st_oid) {
									if (current_img_inst_uid != img_st_oid) {
										document.getElementById('iframe').src = '${dwvUrl}index.html?input=${baseUrl}raw%2F'
												+ img_st_oid;
									}
									current_img_inst_uid = img_st_oid;
									$('#form-image-tab a:last').tab('show');
								};
							</script>
							<c:forEach var="image" items="${presurgical_images}">
								<div class="col-lg-3 col-md-4 col-xs-6 thumb">
									<a class="thumbnail"> <img class="img-responsive" style="height: 180px"
										src="${baseUrl}jpeg/${image.oid}"
										onclick="swich_tab_by_thumbnail('${image.oid}');" />
									</a>
								</div>
							</c:forEach>
							<div class="col-sm-8">
								<button
									onclick="document.getElementById('form').action='${baseUrl}upload/presurgical/${formBean.patient.pseudonym}';document.getElementById('form').method='get';"
									class="btn">Attach image...</button>
							</div>
						</div>
						<div class="form-group">
							<label class="col-lg-6 col-md-6 col-xs-6 control-label">Post chemotherapy/pre-surgical imaging</label>
							<div class="col-sm-6 col-md-6">
								<label class="radio-inline"> <form:radiobutton path="postChemotherapyPreSurgeryImages" value="false" />not done
								</label> <label class="radio-inline"> <form:radiobutton path="postChemotherapyPreSurgeryImages" value="true" />done
								</label>
							</div>
						</div>
						<div class="form-group">
							<label class="col-lg-6 col-md-6 col-xs-6 control-label">Proposed (virtual) gross tumour volume provided?</label>
							<div class="col-sm-6">
								<label class="radio-inline"> <form:radiobutton path="providedGrossTumourVolume" value="true" />yes
								</label> <label class="radio-inline"> <form:radiobutton path="providedGrossTumourVolume" value="false" />no
								</label>
							</div>
						</div>
						<div class="form-group">
							<label class="col-lg-6 col-md-6 col-xs-6 control-label">Proposed clinical target volume provided?</label>
							<div class="col-sm-6">
								<label class="radio-inline"> <form:radiobutton path="providedClinicalTargetVolume" value="true" />yes
								</label> <label class="radio-inline"> <form:radiobutton path="providedClinicalTargetVolume" value="false" />no
								</label>
							</div>
						</div>
						<div class="form-group">
							<label class="col-lg-6 col-md-6 col-xs-6 control-label">Proposed planning target volume provided?</label>
							<div class="col-sm-6">
								<label class="radio-inline"> <form:radiobutton path="providedPlanningTargetVolume" value="true" />yes
								</label> <label class="radio-inline"> <form:radiobutton path="providedPlanningTargetVolume" value="false" />no
								</label>
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="treatmentPlan"> 
								Proposed treatment plan <form:errors path="treatmentPlan" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="treatmentPlan" class="form-control" />
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="fieldAndBeamModification"> 
								Proposed field and beam modification <form:errors path="fieldAndBeamModification" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="fieldAndBeamModification" class="form-control" />
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="doseFractionEnergy"> 
								Proposed dose/fraction/energy <form:errors path="doseFractionEnergy" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="doseFractionEnergy" class="form-control" />
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="doseVolumeHistograms"> 
								Proposed dose/volume histograms <form:errors path="doseVolumeHistograms" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="doseVolumeHistograms" class="form-control" />
							</div>
						</div>
						<br> <br>
					</fieldset>
					<fieldset>
						<legend>Treatment planning images</legend>
						<div class="form-group">
							<c:forEach var="image" items="${treatmentplanning_images}">
								<div class="col-lg-3 col-md-4 col-xs-6 thumb">
									<a class="thumbnail" href="#"> <img class="img-responsive" style="height: 180px"
										src="${baseUrl}jpeg/${image.oid}"
										onclick="swich_tab_by_thumbnail('${image.oid}');" />
									</a>
								</div>
							</c:forEach>
							<div class="col-sm-8">
								<button
									onclick="document.getElementById('form').action='${baseUrl}upload/treatmentplanning/${formBean.patient.pseudonym}';document.getElementById('form').method='get';"
									class="btn">Attach image...</button>
							</div>
						</div>
						<br> <br>
					</fieldset>
					<fieldset>
						<legend>Local Contact Information</legend>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="name"> 
								Name <form:errors path="name" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="name" class="form-control" />
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="eMail"> 
								Email <form:errors path="eMail" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="eMail" class="form-control" />
							</div>
						</div>
						<div class="form-group">
							<form:label class="col-lg-2 control-label" path="phoneNumber"> 
								Phone <form:errors path="phoneNumber" />
							</form:label>
							<div class="col-lg-6">
								<form:input path="phoneNumber" class="form-control" />
							</div>
						</div>
					</fieldset>
					<hr />
					<p>
						<button onclick="document.getElementById('form').action='${baseUrl}${formBean.patient.pseudonym}';document.getElementById('form').method='get';"
							class="btn">Cancel</button>
						<button
							onclick="document.getElementById('processingMode').value='save';document.getElementById('form').action='${baseUrl}upload_info';document.getElementById('form').method='post'; $('#message').offset().top;"
							type="submit" class="btn btn-primary">Save</button>
						<button id="submitButton"
							onclick="document.getElementById('processingMode').value='submit';document.getElementById('form').action='${baseUrl}upload_info';document.getElementById('form').method='post'; $('#message').offset().top;"
							type="submit" class="btn btn-primary">Submit</button>
					</p>
				</div>
				<!-- end of form-tab -->
				<c:import url="/WEB-INF/views/tags/imagetab.jsp" />
			</div>
			<form:hidden path="processingMode" />
		</form:form>
	</div>
	<!-- end of content -->
</body>
</html>
