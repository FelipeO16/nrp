let idEnt = null;

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        $(".container-menu").fadeOut();
        $('.container-config').fadeOut();
        $(".container-menucar").fadeOut();
        $('.container-dialog').fadeOut();
		$(".blooming-menu__container").hide();
        $('body').css('background-color', 'transparent')
        $.post('http://vrp_actions/fechar', JSON.stringify({}));
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
		bloomingMenu.close();
    }
});

$(document).ready(function() {
    /* -------------------------SETTINGS-------------------------- */
    $(".container-config").on('change', '#cine', function() {
        if ($(this).is(':checked')) {
            switchStatus = $(this).is(':checked');
            $.post('http://vrp_actions/configcine', JSON.stringify({ id: true }));
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));
        } else {
            switchStatus = $(this).is(':checked');
            $.post('http://vrp_actions/configcine', JSON.stringify({ id: false }));
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
        }
    });

    $(".container-config").on('change', '#hud', function() {
        if ($(this).is(':checked')) {
            switchStatus = $(this).is(':checked');
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));
        } else {
            switchStatus = $(this).is(':checked');
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
        }
    });

    $(".container-config").on('change', '#tudo', function() {
        if ($(this).is(':checked')) {
            switchStatus = $(this).is(':checked');
            $('#hud').prop('checked', true);
            $('#cine').prop('checked', true);
            $.post('http://vrp_actions/configcine', JSON.stringify({ id: true }));
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));
        } else {
            switchStatus = $(this).is(':checked');
            $('#hud').prop('checked', false);
            $('#cine').prop('checked', false);
            $.post('http://vrp_actions/configcine', JSON.stringify({ id: false }));
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
        }
    });

    /* -------------------------MESSAGE NUI-------------------------- */

    window.addEventListener('message', function(event) {
        let data = event.data;
		if (data.show){
			$(".blooming-menu__container").show();
			bloomingMenu.close().open();
		}
    });
	
	
    var bloomingMenu = new BloomingMenu({
      startAngle: 0,
      endAngle: 270,
      radius: 100,
      itemsNum: 4,
	  itemWidth: 60,
    })
    bloomingMenu.render();

    // Prevents "elastic scrolling" on Safari
    document.addEventListener('touchmove', function(event) {
      'use strict'
      event.preventDefault()
    });
	
	bloomingMenu.props.elements.items.forEach(function (item, index) {
		item.addEventListener('click', function () {
			$(".blooming-menu__container").hide();
			bloomingMenu.close();
			switch(index){
				case 0:
					$.post("http://vrp_actions/inventario");
					break;
					
				case 1:
					$.post("http://vrp_actions/score");
					break;
					
				case 2:
					$('body').css('background-color', '#1f2020e8')
					$('.container-config').fadeIn();
					break;
					
				case 3:
					$('body').css('background-color', '#1f2020e8')
					$('.container-menucar').fadeIn();
					break;
					
			}
		});
	});
})




