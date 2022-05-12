let carroID = null;
let carroPlaca = null;
let motorID = null;
let latariaID = null;
let gasolinaID = null;
$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $(".container-garagem").html('');
        $("#garagem").fadeOut();
        $('body').css('background-color', 'transparent')
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
        $.post('http://vrp_garagem/fechar', JSON.stringify({}));
    }
});

$(document).ready(function() {

    $('.category_carro').click(function() {
        let pegCarro = $(this).attr('category');

        $('.carro-item').css('transform', 'scale(0)');

        function hideCarro() {
            $('.carro-item').hide();
        }
        setTimeout(hideCarro, 400);

        function showCarro() {
            $('.carro-item[category="' + pegCarro + '"]').show();
            $('.carro-item[category="' + pegCarro + '"]').css('transform', 'scale(1)');
        }
        setTimeout(showCarro, 400);
    });

    $('.category_carro[category="all"]').click(function() {
        function showAll() {
            $('.carro-item').show();
            $('.carro-item').css('transform', 'scale(1)');
        }
        setTimeout(showAll, 400);
    });

    $("#garagem").on('click', '#spawn', function() {
        $("#garagem").fadeOut();
        $(".container-garagem").html('');
        $('body').css('background-color', 'transparent');
        $.post('http://vrp_garagem/fechar', JSON.stringify({}));
        $.post('http://vrp_garagem/spawn', JSON.stringify({
            id: carroID,
            placa: carroPlaca,
            motor: motorID,
            lataria: latariaID,
            gasolina: gasolinaID,
			vehicle: carroID,
        }));
    });

    $("#garagem").on('click', '#return', function() {
        $("#garagem").fadeOut();
        $(".container-garagem").html('');
        $('body').css('background-color', 'transparent');
        $.post('http://vrp_garagem/fechar', JSON.stringify({}));
        $.post('http://vrp_garagem/guardar', JSON.stringify({
            id: carroID,
            placa: carroPlaca,
            motor: motorID,
            lataria: latariaID,
            gasolina: gasolinaID,
			vehicle: carroID
        }));
    });
	
	$("#garagem").on('click', '#vender', function() {
        $("#garagem").fadeOut();
        $(".container-garagem").html('');
        $('body').css('background-color', 'transparent');
        $.post('http://vrp_garagem/fechar', JSON.stringify({}));
        $.post('http://vrp_garagem/vender', JSON.stringify({
            id: carroID,
            placa: carroPlaca,
            motor: motorID,
            lataria: latariaID,
            gasolina: gasolinaID,
			vehicle: carroID
        }));
    });
	
	$("#garagem").on("click", ".takecaroutspan", function(){
		setTimeout(function(){
			$("#garagem").fadeOut();
			$(".container-garagem").html('');
			$('body').css('background-color', 'transparent');
			$.post('http://vrp_garagem/fechar', JSON.stringify({}));
			$.post('http://vrp_garagem/pagar', JSON.stringify({
				id: carroID,
				placa: carroPlaca,
				motor: motorID,
				lataria: latariaID,
				gasolina: gasolinaID,
				vehicle: carroID
			}));
		},500);
	});

    window.addEventListener('message', function(event) {
        let data = event.data;
        $('#CasasTotal').html(event.data.quantidade);
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));
        if (data.show) {
            let garagem_data = data.js

            $("#garagem").show();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')
			$("#garagem .title span").text(data.titulo);
            for (let item in garagem_data) {
				if(garagem_data[item].state == 0){
					$(".container-garagem").append(`
					<div onclick="selectItem(this)" class="item carro-item" category="` + garagem_data[item].tipo + `" data-idname="` + garagem_data[item].modelo + `" data-idplaca="` + garagem_data[item].placa + `" data-state="` + garagem_data[item].state + `" data-idmot="` + garagem_data[item].motor + `" data-idlat="` + garagem_data[item].lataria + `" data-idgas="` + garagem_data[item].gasolina + `">
					  <div class="imagem" style="background-image: url('` + garagem_data[item].img + `')"></div>
					  <span id="nome" style="color:#fff !important">` + garagem_data[item].nome + ` | ` + garagem_data[item].placa + `<br><span id="types" style="color:#fff !important">Motor: ` + garagem_data[item].motor + `% | Lataria: ` + garagem_data[item].lataria + `% | Gasolina: ` + garagem_data[item].gasolina + `%</span></span>
					  <span class="icon" id="icon" style="background-color: rgba(46,139,87, 0.4);"><i class="fas fa-car"></i></span>
					</div>`);
				}else if(garagem_data[item].state == 1){
					$(".container-garagem").append(`
                <div onclick="selectItem(this)" class="item carro-item" category="` + garagem_data[item].tipo + `" data-idname="` + garagem_data[item].modelo + `" data-idplaca="` + garagem_data[item].placa + `" data-state="` + garagem_data[item].state + `" data-idmot="` + garagem_data[item].motor + `" data-idlat="` + garagem_data[item].lataria + `" data-idgas="` + garagem_data[item].gasolina + `">
                  <div class="imagem" style="background-image: url('` + garagem_data[item].img + `')"></div>
                  <span id="nome" style="color:#fff !important">` + garagem_data[item].nome + ` | ` + garagem_data[item].placa + `<br><span id="types" style="color:#fff !important">Motor: ` + garagem_data[item].motor + `% | Lataria: ` + garagem_data[item].lataria + `% | Gasolina: ` + garagem_data[item].gasolina + `%</span></span>
                  <span class="icon" id="icon" style="background-color: rgba(64, 158, 255, 0.4);"><i class="fas fa-car"></i></span>
                </div>`);
				}else{
						$(".container-garagem").append(`
                <div onclick="selectItem(this)" class="item carro-item" category="` + garagem_data[item].tipo + `" data-idname="` + garagem_data[item].modelo + `" data-idplaca="` + garagem_data[item].placa + `" data-state="` + garagem_data[item].state + `" data-idmot="` + garagem_data[item].motor + `" data-idlat="` + garagem_data[item].lataria + `" data-idgas="` + garagem_data[item].gasolina + `">
                  <div class="imagem" style="background-image: url('` + garagem_data[item].img + `')"></div>
                  <span id="nome" style="color:#fff !important">` + garagem_data[item].nome + ` | ` + garagem_data[item].placa + `<br><span id="types" style="color:#fff !important">Motor: ` + garagem_data[item].motor + `% | Lataria: ` + garagem_data[item].lataria + `% | Gasolina: ` + garagem_data[item].gasolina + `%</span></span>
                  <span class="icon" id="icon"><span class="takecaroutspan">Pagar Tarifa</span><i class="fas fa-car" style="position: relative;"></i></span>
                </div>`);
				}
            }
        }
    })
});

function selectItem(element) {
    carroID = element.dataset.idname;
    carroPlaca = element.dataset.idplaca;
    motorID = element.dataset.idmot;
    latariaID = element.dataset.idlat;
    gasolinaID = element.dataset.idgas;
    $(".container-garagem div").css("background-color", "transparent");
    $(".container-garagem div").css("border", "0");
    $(element).css("background-color", "rgba(0,0,0,0.20)");
    $('.spawn').removeAttr("disabled");
    $('.return').removeClass("desactive");
    $('.return').removeAttr("disabled");
	$('.vender').removeClass("desactive");
    $('.vender').removeAttr("disabled");
    if (element.dataset.state == 1) {
        $('.tarifa').removeClass("desactive");
        $('.tarifa').removeAttr("disabled");
        $('.return').removeClass("desactive");
        $('.return').removeAttr("disabled");
		$('.vender').addClass("desactive");
        $('.vender').attr("disabled");
        $(element).css('border-right', '1px solid #409eff')
    }
    if (element.dataset.state == 0) {
        $('.tarifa').addClass("desactive");
        $('.tarifa').attr("disabled");
        $('.return').addClass("desactive");
        $('.return').attr("disabled");
		$('.spawn').removeAttr("disabled");
		$('.spawn').removeClass("desactive");
        $(element).css('border-right', '1px solid #1db3189d')
    }
}