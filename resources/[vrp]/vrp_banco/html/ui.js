function addGaps(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + '<span style="margin-left: 3px; margin-right: 3px;"/>' + '$2');
  }
  return x1 + x2;
}

function addCommas(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + '.<span style="margin-left: 0px; margin-right: 1px;"/>' + '$2');
  }
  return x1 + x2;
}

$(document).ready(function() {
  window.addEventListener('message', function(event) {
      var item = event.data;
      $('.identidade').html(event.data.identidade);

      if (item.updateBalance == true) {
          $('.currentBalance').html(' ' + addCommas(event.data.balance));
          $('.username').html(event.data.player);
      }

      if (item.openBank == true) {
          $(".container").fadeIn();

          let banco_data = item.banco
          for (let item in banco_data) {
              $("#extrato").append(`
              <div class="margin">
                  <div class="card-content__title">Extrato (` + banco_data[item].data + `)</div>
                  <div class="card-content__value"><span>` + banco_data[item].extrato + `</span></div>
              </div>
            `);
          }
      }

      if (item.openBank == false) {
          $(".container").fadeOut();
          $('#extrato').html('')
      }
  });

  document.onkeyup = function(data) {
      if (data.which == 27) {
          $.post('http://vrp_banco/close', JSON.stringify({}));
      }
  };

  $("#SaqueRapido").click(function() {
      $.post('http://vrp_banco/quickCash', JSON.stringify({}));
  });

  $("#sacar").submit(function(e) {
      e.preventDefault();
      $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
          amount: $("#sacar #amount").val()
      }));
      $("#sacar #amount").prop('disabled', true)
      setTimeout(function() {
          $("#sacar #amount").prop('disabled', false)
          $("#sacar #submit").css('display', 'block')
      }, 2000)

      $("#sacar #amount").val('')
      $('modal').fadeOut();
  });

  $("#depositar").submit(function(e) {
      e.preventDefault();
      $.post('http://vrp_banco/depositSubmit', JSON.stringify({
          amount: $("#depositar #amount").val()
      }));
      $("#depositar #amount").prop('disabled', true)
      setTimeout(function() {
          $("#depositar #amount").prop('disabled', false)
          $("#depositar #submit").css('display', 'block')
      }, 2000)
      $("#depositar #amount").val('')
      $('modal').fadeOut();
  });

  $("#trans").submit(function(e) {
      e.preventDefault();
      $.post('http://vrp_banco/transferSubmit', JSON.stringify({
          amount: $("#trans #amount").val(),
          toPlayer: $("#trans #toPlayer").val()
      }));
      $("#trans #amount").prop('disabled', true)
      $("#trans #toPlayer").prop('disabled', true)
      setTimeout(function() {
          $("#trans #amount").prop('disabled', false)
          $("#trans #submit").css('display', 'block')
          $("#trans #toPlayer").prop('disabled', false)
      }, 2000)
      $("#trans #amount").val('')
      $("#trans #toPlayer").val('')
      $('modal').fadeOut();
  });

});