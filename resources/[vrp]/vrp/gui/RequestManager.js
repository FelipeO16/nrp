function RequestManager() {
  var _this = this;
  setInterval(function() { _this.tick(); }, 1000);

  this.requests = []
  this.div = document.createElement("div");
  this.div.classList.add("request_manager");

  document.body.appendChild(this.div);
}

RequestManager.prototype.buildText = function(text, time) {
  return "<span>" + text + "<br> <span id=\"act\"><a><span id=\"text1\">Aceitar</span> <span class=\"yes\">F1</span></a><span id=\"time\">" + time + "</span><a><span id=\"text2\">Recusar</span> <span class=\"no\">F2</span></a></span></span>";
}

RequestManager.prototype.addRequest = function(id, text, time) {
  var request = {}
  request.div = document.createElement("div");
  request.id = id;
  request.time = time - 1;
  request.text = text;
  request.div.innerHTML = this.buildText(text, time - 1);

  this.requests.push(request);
  this.div.appendChild(request.div);
}

RequestManager.prototype.respond = function(ok)
  {
      if (this.requests.length > 0) {
          var request = this.requests[0];

          if (this.onResponse)
              this.onResponse(request.id, ok);

          this.div.removeChild(request.div);
          this.requests.splice(0, 1);
      }
  }

RequestManager.prototype.tick = function() {
  for (var i = this.requests.length - 1; i >= 0; i--) {
      var request = this.requests[i];

      request.time -= 1;
      request.div.innerHTML = this.buildText(request.text, request.time);

      if (request.time <= 0) {
          this.div.removeChild(request.div);
          this.requests.splice(i, 1);
      }
  }
}