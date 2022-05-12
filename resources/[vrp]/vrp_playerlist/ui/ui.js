$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $(".container").fadeOut();
        $('body').css('background-color', 'transparent')
        $('#tbody').html('')
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
        $.post('http://vrp_playerlist/fechar', JSON.stringify({}));
        2
    }
});

$(document).ready(function() {

    $('.changeUrl').on('click', function() {
        $('#inputUrl').fadeIn()
    });

    jQuery(function($){                
        $('#formUrl').submit(function(){   
            let foto = $('#inputUrl').val()                 
            $.post('http://vrp_playerlist/changeFoto', JSON.stringify({ img: foto }));
            $.post('http://vrp_playerlist/fechar', JSON.stringify({}));
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
    window.addEventListener('message', function(event) {
        let data = event.data;
        $('#lvl').html(data.lvl);
        $('#adm').html(data.adm);
        $('#nome').html(data.nome);
        $('.avatar').css('background-image', 'url('+data.foto+')');
        $('#phone').html(data.phone);
        $('#register').html(data.register);
        if (data.show) {
            $(".container").fadeIn();
            $('#tbody').append(data.text)
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')
        }
    });
})