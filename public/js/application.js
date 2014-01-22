$(document).ready( function(){
  $("#commandForm").submit(submitMove);
  //$("#settingsForm").submit(submitSettings);

  $(".heading").click( function(){
    $(this).next(".menu").slideToggle();
  });

  $(".room_setting_cb").change( function(){
    var $room_select = $("." + $(this).parent().attr("class") + " .room_select");
    toggleDisabledProp($room_select);
  });

  var $rgc = $(".random_gem_chance");
  $(".random_gems_cb").change( function(){
    toggleDisabledProp($rgc);
  });

  var $prs = $( ".player .room_select" );
  var $grs = $( ".grue .room_select" );

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

$( document ).ajaxStart(function() {
  $( "#loading" ).show();
  loadingAnimation();
});

$( document ).ajaxStop(function() {
  $( "#loading" ).stop().hide();
  // $().trigger("ready");
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

// function submitSettings(ev){
//   ev.preventDefault();
//   var form = $("#settingsForm");
//   $.ajax({
//     timeout:3000,
//     type: form.attr('method'),
//     url: form.attr('action'),
//     data: form.serialize(),
//     dataType: 'html',
//     success: function(data){
//       ev.preventDefault();
//       $("#main").html( data );
//     },
//     complete: function(){
//       updateInfo();
//     }
//   });
// }

function updateInfo(){
  $.get("/info", function( response ) {
      //console.log(response)
      $("#info").html( response );
  });
}

// function updateSettings(){
//   return $.get("/settings", function( response ) {
//     $("#settings").html( response );
//   });
// }

function loadingAnimation(){
  var $loading = $("#loading");
  setInterval(function(){
    $loading.animate({"letter-spacing": "5px"}, 500, function(){
      $loading.animate({"letter-spacing": "0px"}, 500);
    });
  }, 2000);
}

//the replace() is there to find 'option.burntsienna', instead of 'option.burnt sienna'.
//burnt sienna sucks. in so many ways. that's the takeaway moral of the story, kids.
function disableInitialRoomOptions(grs, prs){
  grs.find("option." + prs.val().replace(/\s+/g, '')).prop("disabled", true);
  prs.find("option." + grs.val().replace(/\s+/g, '')).prop("disabled", true);
}

function toggleDisabledProp(obj){
  obj.prop("disabled", function(){                             
    return ! $(this).prop('disabled');
  });
}