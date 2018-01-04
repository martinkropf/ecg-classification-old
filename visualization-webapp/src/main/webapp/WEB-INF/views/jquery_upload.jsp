<!DOCTYPE HTML>
<html>


<body>

<h1>Upload files</h1>

<input id="fileupload" type="file" name="files[]" data-url="/im-showcase/controller/upload" multiple>
<div id="progress">
    <div class="bar" style="width: 0%;"></div>
</div>
<script>

$(function () {
    $('#fileupload').fileupload({
        dataType: 'json',
        add: function (e, data) {
            data.context = $('<button/>').text('Upload')
                .appendTo(document.body)
                .click(function () {
                    data.context = $('<p/>').text('Uploading...').replaceAll($(this));
                    data.submit();
                });
        },
        done: function (e, data) {
            data.context.text('Upload finished.');

        }
    });
});
</script>
</body> 
</html>
