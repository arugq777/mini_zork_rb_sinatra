$(document).ready(function(){
  $("#commandForm").submit(submitMove);
  $("#refreshInfo").on('click','a',updateInfo);
});

function submitMove(ev){
  ev.preventDefault();
  var form = $("#commandForm");
  //form.submit(function(ev){
    //console.log(form.serialize());
  $.ajax({
    timeout:3000,
    type: form.attr('method'),
    url: form.attr('action'),
    data: form.serialize(),
    dataType: 'html',
    success: function(data){
      ev.preventDefault();
      $(data).fadeIn("slow").prependTo('#turns');
    }
  });
}

// function updateExits(event){
//   $.ajax({
//     type: 'get',
//     url: '/exits',
//     dataType: 'html',
//     success: function(response){
//       event.preventDefault();
//       $('.exits').html(response);
//     }
//   })
// }

function updateInfo(event){
  $.get("/info", function( data ) {
      event.preventDefault();
      $( "#info" ).html( data );
  });
}