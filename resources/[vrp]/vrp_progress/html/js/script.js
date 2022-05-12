$('document').ready(function() {
    vRPpg = {};

    vRPpg.Progress = function(data) {
        $("#mina").css({"display":"block"});
        $("#progress-label").text(data.label);
        $("#progress-bar").stop().css({"width": 0, "background-color": "#ff5f00"}).animate({
          width: '100%'
        }, {
          duration: parseInt(data.duration),
          complete: function() {
            $("#mina").css({"display":"none"});
            $("#progress-bar").css("width", 0);
            $.post('http://vrp_progress/concluir', JSON.stringify({
                })
            );
          }
        });
    };

    vRPpg.ProgressCancel = function() {
        $("#mina").css({"display":"block"});
        $("#progress-label").text("CANCELLED");
        $("#progress-bar").stop().css( {"width": "100%", "background-color": "#ff0000"});

        setTimeout(function () {
            $("#mina").css({"display":"none"});
            $("#progress-bar").css("width", 0);
            $.post('http://vrp_progress/cancelar', JSON.stringify({
                })
            );
        }, 1000);
    };

    vRPpg.CloseUI = function() {
        $('.main-container').css({"display":"none"});
        $(".character-box").removeClass('active-char');
        $(".character-box").attr("data-ischar", "false")
        $("#delete").css({"display":"none"});
    };
    
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case 'call_progress':
                vRPpg.Progress(event.data);
                break;
            case 'cancel_progress':
                vRPpg.ProgressCancel();
                break;
        }
    })
});