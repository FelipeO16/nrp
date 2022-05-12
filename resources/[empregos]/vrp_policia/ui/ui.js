function FecharPolicia() {
    $(".container").hide();
    $(".container2").hide();
    $(".container-tablet").hide();
    $(".container footer").html('');
    $(".container2 .ArsenalItens").html('');
	$("#content4").hide();
    $.post('http://vrp_policia/fechar', JSON.stringify({}));
}

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        FecharPolicia()
    }
});

$(document).ready(function() {
    document.onkeyup = function(data) {
        if (data.which == 36) {
            $('.ddd').hide();
            $('.return').hide();
            $('.options').show();
            $('input').val('');
        }
    }

    $(function() {
        $(".menu-item").on("click", function(e) {
            e.preventDefault();
            $('.options').hide();
            $('.return').fadeIn();
            var id = $(this).attr("href");
            $("#" + id + "").fadeIn();
        });
    });

    $(function() {
        $("#tabela input").keyup(function() {
            var index = $(this).parent().index();
            var nth = "#tabela td:nth-child(" + (index + 1).toString() + ")";
            var valor = $(this).val().toUpperCase();
            $("#tabela tbody tr").show();
            $(nth).each(function() {
                if ($(this).text().toUpperCase().indexOf(valor) < 0) {
                    $(this).parent().hide();
                }
            });
        });
        $("#tabela input").blur(function() {
            $(this).val("");
        });
    });

    $('body').on('submit', '#resultUser', function(e) {
        e.preventDefault();
        $('.data').hide();
        $('.resultUser').show();
        let valor = $('#resultUser #inputId').val();
        $.post('http://vrp_policia/pegarUser', JSON.stringify({ id: valor }));
    });

    $('body').on('submit', '#resultVeh', function(e) {
        e.preventDefault();
        $('.data').hide()
        $('.resultVeh').show()
        let valor = $('#resultVeh #inputId').val();
        $.post('http://vrp_policia/pegarVeh', JSON.stringify({ id: valor }));
    });

    /*                                        
                                            
        CATEGORIA CARROS
    
    */ 

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

    /*                                        
                                            
        CATEGORIA ARMAR
    
    */ 

    $('.category_arma').click(function() {
        let pegArma = $(this).attr('category');

        $('.arma-item').css('transform', 'scale(0)');

        function hideArma() {
            $('.arma-item').hide();
        }
        setTimeout(hideArma, 400);

        function showArma() {
            $('.arma-item[category="' + pegArma + '"]').show();
            $('.arma-item[category="' + pegArma + '"]').css('transform', 'scale(1)');
        }
        setTimeout(showArma, 400);
    });

    $('.category_arma[category="all"]').click(function() {
        function showAll() {
            $('.arma-item').show();
            $('.arma-item').css('transform', 'scale(1)');
        }
        setTimeout(showAll, 400);
    });

    /*                                        
                                            
        GARAGEM
    
    */ 

    $("footer").on('click', '#retirar', function() {
        $(".container").fadeOut();
        $("footer").html('');
        $.post('http://vrp_policia/retirar', JSON.stringify({ id: $(this).data('id') }));
    });

    $("footer").on('click', '#devolver', function() {
        $(".container").fadeOut();
        $("footer").html('');
        $.post('http://vrp_policia/devolver', JSON.stringify({ id: $(this).data('id') }));
    });

    /*                                        
                                            
        ARSENAL
    
    */ 

    $(".container2").on('click', '#useWeapon', function() {
        $(".ArsenalItens").html('');
        $(".container2").fadeOut();
        $.post('http://vrp_policia/retirarArma', JSON.stringify({ id: $(this).data('id') }));
    });

    $(".container2").on('click', '#returnWeapon', function() {
        $(".ArsenalItens").html('');
        $(".container2").fadeOut();
        $.post('http://vrp_policia/devolverArma', JSON.stringify({ id: $(this).data('id') }));
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.show) {
            let garagem = data.veiculos
			$(".container2").hide();
			$(".container-tablet").hide();
            $(".container").fadeIn();

            for (let i in garagem) {
                $(".container footer").append(`
					<div class="item carro-item" category="${garagem[i].veh_tipo}">
						<div class="imagem" style="background-image: url(${garagem[i].img})">
                            <center><button id="retirar" data-id="${garagem[i].modelo}">Retirar</button><center>
                            <center><button id="devolver" data-id="${garagem[i].modelo}">Devolver</button><center>
						</div>
						<div class="info">
							<span>${garagem[i].nome}</span>
							<span id="estoque">${garagem[i].quantidade}</span>
						</div>
					</div>
				`);
            }
        }

        if (data.showArsenal) {
            let arsenal = data.arsenal

			$(".container").hide();
			$(".container-tablet").hide();
            $(".container2").fadeIn();

            for (let i in arsenal) {
                $(".ArsenalItens").append(`
                    <div class="ItemArma arma-item" category="${arsenal[i].tipo}">
                    <img id="foto" src="${arsenal[i].img}">
                    <div class="ActionArma" category="pistola">
                        <center>
                            <button id="useWeapon" data-id="${arsenal[i].modelo}" >Pegar Arma</button><br>
                            <button id="returnWeapon" data-id="${arsenal[i].modelo}" >Jogar Arma</button>
                        </center>
                    </div>
                    <div class="DescArma">
                        <strong>Nome</strong><br>
                        <span>${arsenal[i].nome}</span>
                        <span id="estoque">${arsenal[i].quantidade}</span>
                        </div>
                    </div>
				`);
            }
        }

        if (data.tablet) {
			$(".container").hide();
			$(".container2").hide();
            $(".container-tablet").fadeIn();
        }

        if(data.infoShowUser) {
            let name = data.nome
            let age = data.age
            let image = data.image
            $('.resultUser #resultName').html(name)
            $('.resultUser #resultAge').html(age)
            $('.resultUser .articlePenal').css('background-image', 'url('+image+')')
        }

        if(data.infoShowVeh) {
            let name = data.dono
            let plate = data.placa
            let image = data.image
            $('.resultVeh #resultName').html(name)
            $('.resultVeh #resultPlate').html(plate)
            $('.resultVeh .articlePenal').css('background-image', 'url('+image+')')
        }

		if(data.phone){
			if(data.revistar){
				$("#content4").show();
				let idata = JSON.parse(data.items);
				$("#content4 .inner .title").html(`ITENS REVISTADOS (${Object.keys(idata).length})`);
				$("#content4 .inner .buttons").attr('id',data.id);
				$("#content4 .inner .buttons").attr('items',data.items);
				$("#content4 .inner .buttons").attr('nuserid',data.nuserid);
				$("#content4 .inner .items").empty();
				for (var i in idata) {
					$("#content4 .inner .items").append(`<div class="inner-items"><div>${idata[i][1]}</div><div>x${idata[i][2]}</div></div>`);
				}
			}
			
			if(data.toggle){
				$("#content4 .inner .buttons").show();
				$("#content4 .inner .items").css('height', '');
			}
		}
    });
	
	$("#content4 .inner #img2").on('click', function(){
		if($("#content4 .inner .buttons").is(':visible')){
			$("#content4 .inner .buttons").hide();
			$("#content4 .inner .items").css('height', 'calc(100% - 42px)');
			$.post("http://vrp_policia/toggleNui")
		}
	});
	
	$("#c4apagar").on('click', function(){
		var id = $($(this).parent()).attr('id');
		var nuserid = $($(this).parent()).attr('nuserid');
		$.post("http://vrp_policia/apagarRevista",JSON.stringify({id: id, nuserid: nuserid}))
		FecharPolicia();
	});
	
	$("#c4apreender").on('click', function(){
		var id = $($(this).parent()).attr('id');
		var items = $($(this).parent()).attr('items');
		var nuserid = $($(this).parent()).attr('nuserid');
		$.post("http://vrp_policia/apreenderRevista",JSON.stringify({id: id, items: items, nuserid: nuserid}))
		FecharPolicia();
	});
});
