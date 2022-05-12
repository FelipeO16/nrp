$(document).ready(function() {
    window.addEventListener("message", function(event) {
        if (event.data.showing === "success") {
            var html = "<center><div class='notify-item'><a><span>" + event.data.msg + "</span></a></div><br></center>"
            $(html).appendTo(".notify").css('animation', 'slide-in-bottom 0.5s cubic-bezier(0.250, 0.460, 0.450, 0.940) both').delay(6000).fadeOut()
        }
        if (event.data.showing === "error") {
            var html = "<center><div class='notify-item'><a><span>Erro: " + event.data.msg + "</span></a></div><br></center>"
            $(html).appendTo(".notify").css('animation', 'slide-in-bottom 0.5s cubic-bezier(0.250, 0.460, 0.450, 0.940) both').delay(6000).fadeOut()
        }
        if (event.data.showing === "warn") {
            var html = "<center><div class='notify-item'><a><span>Warn: " + event.data.msg + "</span></a></div><br></center>"
            $(html).appendTo(".notify").css('animation', 'slide-in-bottom 0.5s cubic-bezier(0.250, 0.460, 0.450, 0.940) both').delay(6000).fadeOut()
        }
    })
});