let vehModel = null

function CloseConce() {
    $("#carshop").hide();
    document.querySelector(".off-aside").classList.remove("modifier");
    $.post('http://vrp_concessionaria/fechar', JSON.stringify({}));
    $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
    $(".container-item").html('');
    $(".garagem-itens").html('');
    $('.container-item').fadeIn()
    $('.container-anouce').fadeOut()
    $('body').css('background-color', 'transparent')
    $('#fechar').css('display', 'none');
    $('#anunciar').css('display', 'block');
    $('header').fadeIn()
    $('section').fadeIn()
    $('footer').fadeIn()
    $('.info').fadeIn()
    $('.categoria').fadeIn()
}

$(document).ready(function() {

    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            CloseConce()
        }
    });

    $(function() {
        $("#txtBusca").keyup(function() {
            var texto = $(this).val();

            $(".container-item .car-card").removeClass('filter');
            $(".container-item .car-card").each(function() {
                if ($(this).text().indexOf(texto) < 0)
                    $(this).addClass('filter');
            });

        });
    });

    $(".container-item").on('click', '#comprar', function() {
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }))
        $.post('http://vrp_concessionaria/comprar', JSON.stringify({ id: $(this).data('id') }));
        CloseConce()
    });

    $(".container-anouce").on('click', '.enviar', function() {
        let vehNome = $('#nome').val();
        let vehQtd = $('#qtd').val();
        let vehDesc = $('#desc').val();
        let vehImg = $('#imagem').val();
        let vehTipo = $('.option-input').attr('data-tipo');
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }))
        $.post('http://vrp_concessionaria/anunciar', JSON.stringify({
            id: vehModel,
            nome: vehNome,
            tipo: vehTipo,
            qtd: vehQtd,
            desc: vehDesc,
            img: vehImg
        }));
        CloseConce()
    });

    $("#anunciar").click(function() {
        $('#anunciar').css('display', 'none');
        $('#fechar').css('display', 'block');
        $('.categoria').fadeOut();
        $('.container-item').fadeOut();
        $('.container-anouce').delay(300).fadeIn(300);
    });

    $("#fechar").click(function() {
        $('#fechar').css('display', 'none');
        $('#anunciar').css('display', 'block');
        $('.categoria').fadeIn();
        $('.container-item').fadeIn()
        $('.container-anouce').fadeOut()
    });

    $('.category_carro').click(function() {
        let pegCarro = $(this).attr('category');
        console.log(pegCarro);

        function hideCarro() {
            $('.carro-item').hide();
        }
        setTimeout(hideCarro, 400);

        function showCarro() {
            $('.carro-item[category="' + pegCarro + '"]').show();
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

    window.addEventListener('message', function(event) {
        let data = event.data;

        let anouce = data.garagem
        let veiculos = data.veiculos

        $('#identidade').html(event.data.identidade);
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));

        function addComma(num) {
            return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.')
        }

        function verificarQtd(num) {
            if (num == 0) {
                return "Sem estoque!"
            } else {
                return num
            }
        }

        if (data.vip) {
            $('.vip').show();
        }

        if (data.dono) {
            $('#anunciar').css('display', 'block');
            $("#carshop").show();


            for (let ano in anouce) {
                $('.garagem-itens').append(`
                  <div class="garagem-item" onclick="select(this)" data-modelo="${anouce[ano].modelo}">
                    <span><i class="fas fa-car"></i>  ${anouce[ano].nome}:${anouce[ano].placa}  <span id="bola"><i class="fas fa-check"></i></span></span>
                  </div>
              `)
            };

            for (let veh in veiculos) {
                $(".container-item").append(`
                <div class="car-card carro-item" category="${veiculos[veh].tipo}"  style="display:none;">
                  <div class="meta">
                    <div class="photo" style="background-image: url('${veiculos[veh].img}')"></div>
                    <ul class="details">
                      <li>Quantidade: ` + verificarQtd(`${veiculos[veh].quantidade}`) + `</li>
                      <li class="tags">
                        <ul>
                          <li><a>` + addComma(`${veiculos[veh].valor}`) + `</a></li>
                        </ul>
                      </li>
                    </ul>
                  </div>
                  <div class="description">
                    <h1>${veiculos[veh].nome}</h1>
                    <p>${veiculos[veh].descricao}</p>
                    <p class="read-more">
                      <a id="comprar" data-id="` + veiculos[veh].modelo + `" onclick="animation()">Comprar</a>
                    </p>
                  </div>
                </div>  
              `);
            }
            $('.carro-item[category="carro"]').fadeIn();

        } else {
            $('#anunciar').css('display', 'none');
            $("#carshop").show();
            for (let veh in veiculos) {
                $(".container-item").append(`
                <div class="car-card carro-item" category="${veiculos[veh].tipo}"  style="display:none;"> 
                  <div class="meta">
                    <div class="photo" style="background-image: url('${veiculos[veh].img}')"></div>
                    <ul class="details">
                      <li>Quantidade: ` + verificarQtd(`${veiculos[veh].quantidade}`) + `</li>
                      <li class="tags">
                        <ul>
                          <li><a>` + addComma(`${veiculos[veh].valor}`) + `</a></li>
                        </ul>
                      </li>
                    </ul>
                  </div>
                  <div class="description">
                    <h1>${veiculos[veh].nome}</h1>
                    <p>${veiculos[veh].descricao}</p>
                    <p class="read-more">
                      <a id="comprar" data-id="` + veiculos[veh].modelo + `" onclick="animation()">Comprar</a>
                    </p>
                  </div>
                </div>  
                `);
            }
            $('.carro-item[category="carro"]').fadeIn();
        }
    })
});

function select(element) {
    vehModel = element.dataset.modelo;
    $('.garagem-itens div').css('border', '1px solid #ddd');
    $('.garagem-itens div').css('color', '#ddd');
    $(element).css('border', '1px solid #07f51a');
    $(element).css('color', '#07f51a');
}