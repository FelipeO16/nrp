let jobID = null;
let jobXP = null;

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $(".container").fadeOut();
        $(".content").html('');
        $('body').css('background-color', 'transparent')
        $.post('http://vrp_agencia/fechar', JSON.stringify({}));
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
    }
});

$(document).ready(function() {

    $(".container").on('click', '.assinar', function() {
        $(".container").fadeOut();
        $(".content").html('');
        $('body').css('background-color', 'transparent');
        $.post('http://vrp_agencia/fechar', JSON.stringify({}));
        $.post('http://vrp_agencia/assinar', JSON.stringify({
            id: jobID,
            xp: jobXP
        }));
    });

    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.ativa) {
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));
            let agencia_data = data.empregos
            $('#text-level').text(data.level)

            $('.container').fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')
            for (let item in agencia_data) {
                $(".content").append(`
                <div class="item" 
                data-job="` + agencia_data[item].nome + `" 
                data-id="` + agencia_data[item].job + `" 
                data-cash="` + agencia_data[item].cash + `" 
                data-lvl="` + agencia_data[item].lvl + `" 
                data-requi="` + agencia_data[item].requer + `" 
                data-text="` + agencia_data[item].descricao + `" 

                data-img1="` + agencia_data[item].img1 + `" 
                data-img2="` + agencia_data[item].img2 + `" 
                data-img3="` + agencia_data[item].img3 + `" 
                data-img4="` + agencia_data[item].img4 + `" 
                data-img5="` + agencia_data[item].img5 + `" 
                
                onclick="select(this)">
                    <div class="icon"><i class="fas fa-user-tie"></i></div>
                    <div class="info-item">
                        <span>` + agencia_data[item].nome + `</span><br>
                        <span style="font-size: 9px;">Level: <strong>` + agencia_data[item].lvl + `</strong>, Salário: <strong>$` + agencia_data[item].cash + `</strong>, Requisito: <strong>` + agencia_data[item].requer + `</strong></span>
                    </div>
                </div>
              `);
            }

            $('.item').on('click', function() {
                $('.arrow').fadeIn();
                $('.agencia').fadeOut(300);
                $('.nivel').fadeOut()
                $('.container-select').fadeIn()
            });
        }

    });

})

function select(element) {
    jobID = element.dataset.id;
    jobXP = element.dataset.lvl;
    $('#job').text(element.dataset.job);
    $('#cash').text(element.dataset.cash);
    $('#lvl').text(element.dataset.lvl);
    $('#requi').text(element.dataset.requi);
    $('#desc').text(element.dataset.text);

    $('#img1').css('background-image', 'url(' + element.dataset.img1 + ')');
    $('#img2').css('background-image', 'url(' + element.dataset.img2 + ')');
    $('#img2').css('background-image', 'url(' + element.dataset.img3 + ')');
    $('#img4').css('background-image', 'url(' + element.dataset.img4 + ')');
    $('#img5').css('background-image', 'url(' + element.dataset.img5 + ')');
}