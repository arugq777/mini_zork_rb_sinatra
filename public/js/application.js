$(document).ready( function(){
  //Click 'INFO' or 'SETTINGS' to slide panel up or down
  $(".heading").click( function(){
    $(this).next(".menu").slideToggle();
  });

  //event listeners for form submits
  $("#commandForm").submit(submitMove);
  $("#settingsForm").submit(submitSettings);

  //event listeners for checkboxes; when triggered,
  //they enable or disable the associated form input
  $(".room_setting_cb").change( function(){
    var $room_select = $("." + $(this).parent().attr("class") + " .room_select");
    toggleDisabledProp($room_select);
  });

  var $rgc = $(".random_gem_chance");
  $(".random_gems_cb").change( function(){
    toggleDisabledProp($rgc);
  });

  //functions and event listeners for disabling conflicting
  //options within dropdown lists. whenever a player room
  //or grue room is selected, that option becomes disabled
  //in the other list.
  var $prs = $( ".player .room_select" );
  var $grs = $(   ".grue .room_select" );

  disableInitialRoomOptions($grs, $prs);

  $prs.change(function(){
    $grs.find("option")
      .prop("disabled", false);
    $grs.find( "option." + $(this).val().replace(/\s+/g, '') )
      .prop("disabled", true);
  });

  $grs.change(function(){
    $prs.find("option")
      .prop("disabled", false);
    $prs.find( "option." + $(this).val().replace(/\s+/g, '') )
      .prop("disabled", true);
  });
});

//a rudimentary 'loading' animation is triggered on 
//each ajax call
$( document ).ajaxStart(function() {
  $( "#loading" ).show();
  loadingAnimation();
});
//and then stopped.
$( document ).ajaxStop(function() {
  $( "#loading" ).hide();
});

//when a move is submitted, a turn partial is received
//and prepended to the #turn ul
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
    error: function() {
      error();
    },
    complete: function(){
      updateInfo();
      $( "#loading" ).stop();
    }
  });
}

//when settings are submitted, #main is refreshed,
//wiping out the previous game. #info is refreshed,
//while #settings stay the same, which makes sense as
//they were just submitted.
function submitSettings(ev){
  ev.preventDefault();
  var form = $("#settingsForm");
  $.ajax({
    timeout:3000,
    type: form.attr('method'),
    url: form.attr('action'),
    data: form.serialize(),
    dataType: 'html',
    success: function(data){
      ev.preventDefault();
      $("#main").html( data );
    },
    error: function() {
      error();
    },
    complete: function(){
      updateInfo();
      $( "#loading" ).stop();
    }
  });
}

//a very general, unhelpful error message.
function error(){
  $( ".error").show();
}

function updateInfo(){
  $.get("/info", function( response ) {
      //console.log(response)
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

//the replace() is there to find 'option.burntsienna', instead of 'option.burnt sienna'.
//burnt sienna sucks, in sooo many ways. that's the takeaway moral of the story, kids.
function disableInitialRoomOptions(grs, prs){
  grs.find("option." + prs.val().replace(/\s+/g, '')).prop("disabled", true);
  prs.find("option." + grs.val().replace(/\s+/g, '')).prop("disabled", true);
}

function toggleDisabledProp(obj){
  obj.prop("disabled", function(){                             
    return ! $(this).prop('disabled');
  });
}
