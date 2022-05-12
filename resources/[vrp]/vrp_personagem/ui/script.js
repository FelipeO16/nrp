$(document).ready(function(){

  // Listen for NUI Events
  window.addEventListener('message', function(event){
    // Open Skin Creator
    if(event.data.openSkinCreator == true){
      $(".skinCreator").css("display","block");
      $(".rotation").css("display","block");
    }
    // Close Skin Creator
    if(event.data.openSkinCreator == false){
      $(".skinCreator").fadeOut(400);
      $(".rotation").fadeOut(400);
    }
  });

  // Form update
  $('input').change(function(){
    $.post('http://vrp_personagem/updateSkin', JSON.stringify({
      value: false,
      // Face
      dad: $('input[name=pere]:checked', '#formSkinCreator').val(),
      mum: $('input[name=mere]:checked', '#formSkinCreator').val(),
      dadmumpercent: $('.morphologie').val(),
      skin: $('input[name=peaucolor]:checked', '#formSkinCreator').val(),
      eyecolor: $('input[name=eyecolor]:checked','#formSkinCreator').val(),
      acne: $('.acne').val(),
      skinproblem: $('.pbpeau').val(),
      freckle: $('.tachesrousseur').val(),
      wrinkle: $('.rides').val(),
      wrinkleopacity: $('.rides').val(),
      hair: $('.hair').val(),
      haircolor: $('input[name=haircolor]:checked', '#formSkinCreator').val(),
      eyebrow: $('.sourcils').val(),
      eyebrowopacity: $('.epaisseursourcils').val(),
      beard: $('.barbe').val(),
      beardopacity: $('.epaisseurbarbe').val(),
      beardcolor: $('input[name=barbecolor]:checked', '#formSkinCreator').val(),
      // Clothes
      hats: $('.chapeaux .active').attr('data'),
      glasses: $('.lunettes .active').attr('data'),
      ears: $('.oreilles .active').attr('data'),
      tops: $('.hauts .active').attr('data'),
      pants: $('.pantalons .active').attr('data'),
      shoes: $('.chaussures .active').attr('data'),
      watches: $('.montre .active').attr('data'),
      braco: $('.braco .active').attr('data'),
    }));
  });
  $('.arrow').on('click', function(e){
    e.preventDefault();
    $.post('http://vrp_personagem/updateSkin', JSON.stringify({
      value: false,
      // Face
      dad: $('input[name=pere]:checked', '#formSkinCreator').val(),
      mum: $('input[name=mere]:checked', '#formSkinCreator').val(),
      dadmumpercent: $('.morphologie').val(),
      skin: $('input[name=peaucolor]:checked', '#formSkinCreator').val(),
      eyecolor: $('input[name=eyecolor]:checked','#formSkinCreator').val(),
      acne: $('.acne').val(),
      skinproblem: $('.pbpeau').val(),
      freckle: $('.tachesrousseur').val(),
      wrinkle: $('.rides').val(),
      wrinkleopacity: $('.rides').val(),
      hair: $('.hair').val(),
      haircolor: $('input[name=haircolor]:checked', '#formSkinCreator').val(),
      eyebrow: $('.sourcils').val(),
      eyebrowopacity: $('.epaisseursourcils').val(),
      beard: $('.barbe').val(),
      beardopacity: $('.epaisseurbarbe').val(),
      beardcolor: $('input[name=barbecolor]:checked', '#formSkinCreator').val(),
      // Clothes
      hats: $('.chapeaux .active').attr('data'),
      glasses: $('.lunettes .active').attr('data'),
      ears: $('.oreilles .active').attr('data'),
      tops: $('.hauts .active').attr('data'),
      pants: $('.pantalons .active').attr('data'),
      shoes: $('.chaussures .active').attr('data'),
      watches: $('.montre .active').attr('data'),
      braco: $('.braco .active').attr('data'),
    }));
  });

  // Form submited
  $('.yes').on('click', function(e){
    e.preventDefault();
    if(document.getElementById("nome").value == "" || document.getElementById("idade").value < 18 || document.getElementById("sobr").value == ""){
      $('.erromsg').fadeIn(10000);
      $(".erromsg").fadeOut();
    } else {
      $('.successmsg').fadeIn(200);
      $('.successmsg').fadeOut();
      $(".skinCreator").fadeOut(400);
      $(".rotation").fadeOut(400);
      $.post('http://vrp_personagem/criar', JSON.stringify({
        value: true,
        nome: $('input[name=nome]', '#formSkinCreator').val(),
        sobrenome: $('input[name=sobrenome]', '#formSkinCreator').val(),
        idade: $('input[name=idade]', '#formSkinCreator').val(),
      }));
    }
  }); 
    $("#right").click(function(){
    $.post('http://vrp_personagem/rotateleftheading', JSON.stringify({
      value: 10
    }));
   });

   $("#left").click(function(){
    $.post('http://vrp_personagem/rotaterightheading', JSON.stringify({
      value: 10
    }));
   });

   $(".masculino").click(function(){
    $.post('http://vrp_personagem/masculino', JSON.stringify({}));
    $('#rostom').fadeIn()
    $('#rostof').fadeOut()
   });

   $(".feminino").click(function(){
    $.post('http://vrp_personagem/feminino', JSON.stringify({}));
    $('#rostof').fadeIn()
    $('#rostom').fadeOut()
   });
   
  $('.tab a').on('click', function(e){
    e.preventDefault();
    $.post('http://vrp_personagem/zoom', JSON.stringify({
      zoom: $(this).attr('data-link')
    }));
  });
  
  $('.identity .group .input #idade').on('change', function () {
		$(".rangeShow").val($(this).val());
	});
});
