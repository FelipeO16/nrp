let itemID = null;
let itemPeso = null;
let itemAmount = null;

function CloseInventory() {
    $('body').css('background-color', 'transparent')
    $("#inventario").fadeOut();
    $('.input').fadeOut()
    $('#inventario').css('filter', 'blur(0px)')
    $("button").prop("disabled", true);

    $('#bau').hide();
    $('#bauCar').hide();
    $('#nuserBau').hide();

    $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
    $.post('http://vrp_inventario/fechar', JSON.stringify({}));
}

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        CloseInventory();
    }
});

$(document).ready(function() {

    $(function() {
        $("#txtBusca").keyup(function() {
            var texto = $(this).val();
            $(".principal .item").removeClass('filter');
            $(".principal .item").each(function() {
                if ($(this).text().indexOf(texto) < 0)
                    $(this).addClass('filter');
            });
        });
    });

    window.addEventListener('message', function(event) {
        let data = event.data;
        $('.money').html(event.data.dinheiro);
        $(".kg").css("height", Math.round(data.hue * 100) + "%");
        $("#peso").html(data.weight);
        $("#max").html(data.max_weight);
        $('.identidade').html(data.identidade);

        if (data.show) {
            let item_inventory = data.inventario;
            $("#inventario").fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')

            $(".principal").empty();
			
            for (let item in item_inventory) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)
                $(".principal").append(`
                <div id="ali" data-weight="${item_inventory[item].iweight}" data-amount="${item_inventory[item].amount}" data-idname="${item}" class="item">
                    <div class="icon"><img src="icons/${res}.png"></div>
                        <a>${item_inventory[item].name}</a>
                    <div class="right" style="margin-right: 5px">
                        <span id="${item}">${item_inventory[item].amount}x</span>
                    </div>
                    <div class="right" style="margin-right: 30px">
                        <span>${item_inventory[item].iweight}kg</span>
                    </div>
                </div>
                `);
            }
            $('.principal .item').draggable({
                helper: 'clone',
                opacity: 0.35,
                zIndex: 99999,
                revert: 'invalid',
                start: function(event, ui) {
                    $('#usar').removeAttr('disabled');
                    $('#dropar').removeAttr('disabled')
                    $('#bau').css('background-color', 'rgba(0,0,0,0.10)');
                    selectItem(this);
                },
                stop: function() {
                    $('#usar').attr('disabled', true);
                    $('#dropar').attr('disabled', true)
                    $('#bau').css('background-color', 'transparent');
                }
            });
        }

        if (data.showSecundary) {
            let inventory_secundary = data.InventarioSecundario;

            $("#inventario").fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)');

            $('#bau').show();
            $('#principal').show();

            $('#bauCar').hide();
            $('#bauCars').hide();
            $('#nuserBau').hide();

            $("#bau").empty();
            for (let item in inventory_secundary) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)

                $("#bau").append(`
                <div id="ali" data-weight="${inventory_secundary[item].iweight}" data-amount="${inventory_secundary[item].amount}" data-idname="${item}" class="item">
                    <div class="icon"><img src="icons/${res}.png"></div>
                        <a>${inventory_secundary[item].name}</a>
                    <div class="right" style="margin-right: 5px">
                        <span>${inventory_secundary[item].amount}x</span>
                    </div>
                    <div class="right" style="margin-right: 30px">
                        <span>${inventory_secundary[item].iweight}kg</span>
                    </div>
                </div>
                `);
            }
            $('#bau .item').draggable({
                helper: 'clone',
                opacity: 0.35,
                zIndex: 99999,
                revert: 'invalid',
                start: function(event, ui) {
                    $('#usar').droppable("disable")
                    $('#dropar').droppable("disable")
                    $('#bau').droppable("disable")
                    $('.container-item').css('background-color', 'rgba(0,0,0,0.10)');
                    selectItem(this);
                },
                stop: function() {
                    $('#usar').droppable("enable")
                    $('#dropar').droppable("enable")
                    $('#bau').droppable("enable")
                    $('.container-item').css('background-color', 'transparent');
                }
            });
        }

        if (data.showSecundaryCar) {
            let inventory_secundary = data.InventarioSecundarioCar;

            $("#inventario").fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)');

            $('#bauCar').show();
            $('#bauCars').show();

            $('#bau').hide();
            $('#nuserBau').hide();
            $('#principal').hide();

            $("#bauCar").empty();
            for (let item in inventory_secundary) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)

                $("#bauCar").append(`
                <div id="ali" data-weight="${inventory_secundary[item].iweight}" data-amount="${inventory_secundary[item].amount}" data-idname="${item}" class="item">
                    <div class="icon"><img src="icons/${res}.png"></div>
                        <a>${inventory_secundary[item].name}</a>
                    <div class="right" style="margin-right: 5px">
                        <span>${inventory_secundary[item].amount}x</span>
                    </div>
                    <div class="right" style="margin-right: 30px">
                        <span>${inventory_secundary[item].iweight}kg</span>
                    </div>
                </div>
                `);
            }
            $('#bauCar .item').draggable({
                helper: 'clone',
                opacity: 0.35,
                zIndex: 99999,
                revert: 'invalid',
                start: function(event, ui) {
                    $('#usar').droppable("disable");
                    $('#dropar').droppable("disable");
                    $('#bauCar').droppable("disable");
                    $('.container-item').css('background-color', 'rgba(0,0,0,0.10)');
                    selectItem(this);
                },
                stop: function() {
                    $('#usar').droppable("enable")
                    $('#dropar').droppable("enable")
                    $('#bauCar').droppable("enable")
                    $('.container-item').css('background-color', 'transparent');
                }
            });
        }

        if (data.nuserBau) {
            let inventory_secundary = data.inventarioNuser;

            $("#inventario").fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)');

            $('#nuserBau').show();
            $('#userBau').show();

            $('#bau').hide();
            $('#bauCars').hide();
            $('#principal').hide();

            $("#nuserBau").empty();
            for (let item in inventory_secundary) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)

                $("#nuserBau").append(`
                <div id="ali" data-weight="${inventory_secundary[item].iweight}" data-amount="${inventory_secundary[item].amount}" data-idname="${item}" class="item">
                    <div class="icon"><img src="icons/${res}.png"></div>
                        <a>${inventory_secundary[item].name}</a>
                    <div class="right" style="margin-right: 5px">
                        <span>${inventory_secundary[item].amount}x</span>
                    </div>
                    <div class="right" style="margin-right: 30px">
                        <span>${inventory_secundary[item].iweight}kg</span>
                    </div>
                </div>
                `);
            }
            $('#nuserBau .item').draggable({
                helper: 'clone',
                opacity: 0.35,
                zIndex: 99999,
                revert: 'invalid',
                start: function(event, ui) {
                    $('#usar').droppable("disable");
                    $('#dropar').droppable("disable");
                    $('#nuserBau').droppable("disable");
                    $('.container-item').css('background-color', 'rgba(0,0,0,0.10)');
                    selectItem(this);
                },
                stop: function() {
                    $('#usar').droppable("enable")
                    $('#dropar').droppable("enable")
                    $('#nuserBau').droppable("enable")
                    $('.container-item').css('background-color', 'transparent');
                }
            });
        }

    });
});

function selectItem(element) {
    itemID = element.dataset.idname;
    $(".container-item div").css("border", "0");
    $(element).css("border-right", "2px solid #1db318");
}

$("#bau").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparBau', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#bauCar").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparBauCar', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#nuserBau").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparBauUser', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#principal").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {

            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparInv', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#bauCars").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {

            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparInvCar', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#userBau").droppable({
    tolerance: "pointer",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Enviar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {

            if (result.value) {
                if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/droparInvUser', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#usar").droppable({
    tolerance: "pointer",
    hoverClass: "drop-hover",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Usar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.value) {
                if (result.value == "0" || result.value == "" || result.value == null) {
                    Swal.fire(
                        'Atenção',
                        'Insira uma quantidade válida!',
                        'warning'
                    )
                } else if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/usar', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});

$("#dropar").droppable({
    tolerance: "pointer",
    hoverClass: "drop-hover",
    drop: function(event, ui) {

        idname = ui.draggable.data("idname");
        itemPeso = ui.draggable.data("weight");
        itemAmount = ui.draggable.data("amount");

        Swal.fire({
            title: 'Digite a quantidade',
            input: 'number',
            showCancelButton: true,
            confirmButtonText: 'Dropar',
            cancelButtonText: 'Cancelar',
        }).then((result) => {
            if (result.value) {
                if (result.value == "0" || result.value == "" || result.value == null) {
                    Swal.fire(
                        'Atenção',
                        'Insira uma quantidade válida!',
                        'warning'
                    )
                } else if (result.value > parseInt(itemAmount)) {
                    Swal.fire(
                        'Atenção',
                        'Você não possui a quantidade selecionada.',
                        'warning'
                    )
                } else {
                    $.post('http://vrp_inventario/dropar', JSON.stringify({ id: idname, qtd: result.value }));
                }
            }
        })
    }
});