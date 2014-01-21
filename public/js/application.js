$(document).ready(function(){
  $("#commandForm").submit(submitMove);

  $(".header").click(function(){
    $(this).next(".menu").slideToggle();
  });

  $(".room_setting_cb").change(function(){
    $(this)
      .parent()
      .find(".room_select")
      .prop("disabled", function(){                             
        return ! $(this).prop('disabled');
    });
  });

  var $prs = $(".player .room_select");
  var $grs = $(".grue .room_select");
  disableInitialRoomOptions($grs, $prs);

  $prs.change(function(){
    $grs.find("option").prop("disabled", false);
    $grs.find("option." + $(this).val()).prop("disabled", true);
  });

  $grs.change(function(){
    $prs.find("option").prop("disabled", false);
    $prs.find("option." + $(this).val()).prop("disabled", true);
  });
});

$( document ).ajaxStart(function() {
  $( "#loading" ).show();
  loadingAnimation();
});

$( document ).ajaxStop(function() {
  $( "#loading" ).stop().hide();
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

function loadingAnimation(){
  var $loading = $("#loading");
  setInterval(function(){
    $loading.animate({"letter-spacing": "5px"}, 500, function(){
      $loading.animate({"letter-spacing": "0px"}, 500);
    });
  }, 2000);
}

function disableInitialRoomOptions(grs, prs){
  grs.find("option." + prs.val()).prop("disabled", true);
  prs.find("option." + grs.val()).prop("disabled", true);
}