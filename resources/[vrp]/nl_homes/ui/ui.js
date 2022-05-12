$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $('.homeClothe').hide();
        $('.containerClothe').html('');
        $.post('http://nl_homes/fechar', JSON.stringify({}));
    }
});

$('#saveClothe').on('click', function() {
    $('.createsClothe').hide();
    $('.saveClothes').fadeIn();
});

$('#returnHome').on('click', function() {
    $('.createsClothe').fadeIn();
    $('.sectionClothe').hide();
});

$(document).ready(function() {

    $('.salvarClothe-btn').on('click', function() {
        $('#formClothe').fadeIn();
    })

    $('#formClothe').on('click', function() {
        let nameSet = $('#inputSave').val();
        $.post('http://nl_homes/salvarRoupa', JSON.stringify({ nome: nameSet }));
        $('#formSave').fadeOut();
        $('#inputSave').val('')
    });

    $(".clotheContent").on('click', '#vestir', function() {
        $.post('http://nl_homes/usarSet', JSON.stringify({ useSet: $(this).data('id') }));
    });

    $(".deleteSet").on("click", function() {
        $.post('http://nl_homes/deletarSet', JSON.stringify({ dataSet: dataSet }));
    });

    window.addEventListener('message', function(event) {
        let data = event.data;
		console.log(data.guardaRoupa);
		if(data.guardaRoupa == 2){
			$(".containerClothe").html("");
		}

        if (data.guardaRoupa) {
            $('.homeClothe').fadeIn();

            let roupas = data.roupaSets
            for (let item of Object.keys(roupas)) {
                $(".containerClothe").append(`
                    <div data-json="${roupas[item].nomeSet}" class="clotheItem">
                        <div class="iconClothe">
                            <i class="fas fa-cube"></i>
                        </div>
                        <span>${roupas[item].nomeSet}</span>
                    </div>
                `);
            }
            $('.clotheItem').draggable({
                helper: 'clone',
                opacity: 0.35,
                zIndex: 99999,
                revert: 'invalid',
                start: function(event, ui) {
                    selectItem(this);
                    $('#usar').removeAttr('disabled');
                    $('#dropar').removeAttr('disabled')
                    $('#bau').css('background-color', 'rgba(0,0,0,0.10)');
                },
                stop: function() {
                    $('#usar').attr('disabled', true);
                    $('#dropar').attr('disabled', true)
                    $('#bau').css('background-color', 'transparent');
                }
            });
        } 
    });

});

$("#trashClothe").droppable({
    tolerance: "pointer",
    hoverClass: "drop-hover",
    drop: function(event, ui) {
        idname = ui.draggable.data("json");
        $.post('http://nl_homes/removeSet', JSON.stringify({ useSet: idname }));
    }
});

$("#useClothe").droppable({
    tolerance: "pointer",
    hoverClass: "use-hover",
    drop: function(event, ui) {
        idname = ui.draggable.data("json");
        $.post('http://nl_homes/usarSet', JSON.stringify({ useSet: idname }));
    }
});

function selectItem(element) {
    $(".clotheItem").css("background-color", "rgba(0, 0, 0, 0.20)");
    $(element).css("background-color", "rgba(89, 247, 57, 0.2)");
}