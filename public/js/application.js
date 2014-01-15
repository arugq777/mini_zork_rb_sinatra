$(document).ready(function(){
  $("#commandForm").submit(submitMove);
});

function submitMove(ev){
  ev.preventDefault();
  var form = $("#commandForm");
  $.ajax({
    timeout:3000,
    type: form.attr('method'),
    url: form.attr('action'),
    data: form.serialize(),
    dataType: 'html',
    success: function(data){
      ev.preventDefault();
      $(data).fadeIn("slow").prependTo('#turns');
    },
    complete: function(){
      updateInfo();
    }
  });
}

function updateInfo(){
  $.get("/info", function( response ) {
      $("#info").html( response );
  });
}