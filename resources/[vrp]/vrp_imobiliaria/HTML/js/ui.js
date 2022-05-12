CasaID = null
nomeCasa = null

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $(".tudo").hide();
        $(".casas-venda").html('');
        $.post('http://vrp_imobiliaria/fechar', JSON.stringify({}));
    }
});

function AbrirImobilia() {
    nomeCasa = document.getElementById('nomecasa');
    $(".tudo").show();
}

function TrocarCasa(element) {
    let imagemCasa = element.dataset.img;
    nomeCasa.innerHTML = element.dataset.nomecasa;
    CasaID = element.dataset.id;
    $('.logo').attr('src', imagemCasa);;
}


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


    /*
    



    */

    $(".tudo").on('click', '.visitar', function() {
        $.post('http://vrp_imobiliaria/visitar', JSON.stringify({ info: CasaID }));
        $.post('http://vrp_imobiliaria/fechar', JSON.stringify({}));
        $(".casas-venda").html('');
        $(".tudo").hide();
    });

    $(".tudo").on('click', '#comprar', function() {
        $.post('http://vrp_imobiliaria/comprar', JSON.stringify({ casa: $(this).data('id') }));
        $.post('http://vrp_imobiliaria/fechar', JSON.stringify({}));
        $(".casas-venda").html('');
        $(".tudo").hide();
    });

    $(".tudo").on('click', '#close', function() {
        FecharImobilia()
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        function addComma(num) {
            return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.')
        }

        if(data.stream) {
            $('#casasStream').show();
        }

        if(data.vip) {
            $('#casasVip').show();
        }

        if (data.show) {
            let data_casa = data.casas
            AbrirImobilia()
            $('#CasasTotal').html(event.data.quantidade);
            for (let item of data_casa) {
                if (item) {
                    const localizacao = item.localizacao
                    const obj = JSON.parse(localizacao)
                    $(".casas-venda").delay( 900 ).append(`
                      <div class="item-casa carro-item" onclick="TrocarCasa(this)" data-img="` + item.img + `" data-id="` + [obj.x, obj.y, obj.z, item.id] + `" data-nomecasa="` + item.nome + `" category="` + item.categoria + `" style="display:none;">
                        <div class="item-imagem" style="background-image: url(` + item.img + `);">
                            <div class="item-titulo"><span style="text-transform: uppercase">RESIDÊNCIA ` + item.categoria + `</span></div>
                        </div>
                        <p>` + item.nome + `</p>
                        <div class="item-compra">
                            <span>$` + addComma(item.preco) + `</span>
                            <a id="comprar" data-id="` + [item.nome, item.preco] + `">Comprar</a>
                        </div>
                        <p>North Los Santos</p>
                      </div>
                  `);
                }
            }
            $('.carro-item[category="casa"]').show();
        }
    });
});

$(() => {
    $('.block').on('click', function() {
        $('.block').removeClass('active');
        $(this).addClass("active");
    });
});