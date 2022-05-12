

function FecharGaragem() {
	$(".container").fadeOut();
	$(".container2").fadeOut();
	$("footer").html('');
	$(".ArsenalItens").html('');
    $.post('http://vrp_ems/fechar', JSON.stringify({}));
}

$(document).keyup(function(e) {
     if (e.key === "Escape") {
        FecharGaragem()
    }
});

$(document).ready(function() {
	$('.category_carro').click(function(){
		let pegCarro = $(this).attr('category');

		$('.carro-item').css('transform', 'scale(0)');
		function hideCarro(){
			$('.carro-item').hide();
		} setTimeout(hideCarro,400);

		function showCarro(){
			$('.carro-item[category="'+pegCarro+'"]').show();
			$('.carro-item[category="'+pegCarro+'"]').css('transform', 'scale(1)');
		} setTimeout(showCarro,400);
	});

	$('.category_carro[category="all"]').click(function(){
		function showAll(){
			$('.carro-item').show();
			$('.carro-item').css('transform', 'scale(1)');
		} setTimeout(showAll,400);
	});

	

	$('.category_arma').click(function(){
		let pegArma = $(this).attr('category');

		$('.arma-item').css('transform', 'scale(0)');
		function hideArma(){
			$('.arma-item').hide();
		} setTimeout(hideArma,400);

		function showArma(){
			$('.arma-item[category="'+pegArma+'"]').show();
			$('.arma-item[category="'+pegArma+'"]').css('transform', 'scale(1)');
		} setTimeout(showArma,400);
	});

	$('.category_arma[category="all"]').click(function(){
		function showAll(){
			$('.arma-item').show();
			$('.arma-item').css('transform', 'scale(1)');
		} setTimeout(showAll,400);
	});


	$("footer").on('click', '#retirar', function () {
		$(".container").fadeOut();
		$("footer").html('');
		$.post('http://vrp_ems/retirar', JSON.stringify({id: $(this).data('id')}));
	});

	$(".ArsenalItens").on('click', '#retirar-arma', function () {
		$(".container2").fadeOut();
		$(".ArsenalItens").html('');
		$.post('http://vrp_ems/retirarArma', JSON.stringify({id: $(this).data('id')}));
	});
	
	$(".ArsenalItens").on('click', '#devolver-arma', function () {
		$(".container2").fadeOut();
		$(".ArsenalItens").html('');
		$.post('http://vrp_ems/devolverArma', JSON.stringify({id: $(this).data('id')}));
	});

    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.show) {
			let garagem = data.veiculos
			
			$(".container").fadeIn();

			for (let i in garagem) {
				$("footer").append(`
					<div class="item carro-item" category="${garagem[i].veh_tipo}">
						<div class="imagem" style="background-image: url(${garagem[i].img})">
							<center><button id="retirar" data-id="${garagem[i].modelo}">Retirar</button><center>
						</div>
						<div class="info">
							<strong>Nome</strong><br>
							<span>${garagem[i].nome}</span>
							<span id="estoque">${garagem[i].quantidade}</span>
						</div>
					</div>
				`);
			}
		} else if (data.showArsenal) {
			let arsenal = data.arsenal

			$(".container2").fadeIn();

			for (let i in arsenal) {
				$(".ArsenalItens").append(`
					<iv class="ItemArma arma-item" category="${arsenal[i].tipo}">
						<img id="foto" src="${arsenal[i].img}">
						<div class="ActionArma" category="${arsenal[i].tipo}">
							<center>
                        		<button id="retirar-arma" data-id="${arsenal[i].modelo}">Pegar Arma</button><br>
                        		<button id="devolver-arma" data-id="${arsenal[i].modelo}">Devolver Arma</button>
                    		</center>
						</div>
						<div class="DescArma">
							<strong style="color: #fff">Nome</strong><br>
							<span>${arsenal[i].nome}</span>
							<span id="estoque">${arsenal[i].quantidade}</span>
						</div>
					</div>
				`);
			}
		}
		
    })
});