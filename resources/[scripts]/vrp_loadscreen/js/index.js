var lib = 
{
    rand: function(min, max)
    {
        return min + Math.floor(Math.random()*max);
    },

    fadeInOut: function(duration, elementId, min, max)
    {
        var halfDuration = duration / 2;

        setTimeout(function()  
        {
            var element = document.getElementById(elementId);
            element.style.opacity = min;

            setTimeout(function()  
            {
                element.style.opacity = max;

            }, halfDuration);  

        }, halfDuration);
    },
}
var cursor = $('.cursor');

$(document).bind('mousemove', function (e) {
    var offset = $(window).scrollTop();
    TweenLite.to(cursor, 0, {left: e.pageX - 20, top: e.pageY - offset - 20});
});
    
    var hoverElem = $('body a')
    hoverElem.on('mouseenter', function () {
        TweenLite.to(cursor, 0.6, {
            ease: Elastic.easeOut.config(1, 0.4),
            scale: 0.6,
            backgroundColor: 'blue'
        })
    });
    hoverElem.on('mouseleave', function () {
        TweenLite.to(cursor, 0.6, {
            ease: Elastic.easeOut.config(1, 0.4),
            scale: 1,
            backgroundColor: 'transparent'
        })
    });
      window.revealConfig = {
        controls: true,
        progress: true,
        history: true,
        center: /^\s*(true|1)\s*$/i.test("true"),
        slideNumber: /^\s*(true|1)\s*$/i.test("true"),
        dependencies: [
          { src: 'https://cdn.jsdelivr.net/reveal.js/2.6.2/lib/js/classList.js', condition: function() { return !document.body.classList; } },
          { src: 'https://cdn.jsdelivr.net/reveal.js/2.6.2/plugin/zoom-js/zoom.js', async: true, condition: function() { return !!document.body.classList; } },
          { src: 'https://cdn.jsdelivr.net/reveal.js/2.6.2/plugin/notes/notes.js', async: true, condition: function() { return !!document.body.classList; } },
        ],
    };
    function revealAddFragments() {
      [].forEach.call(document.querySelectorAll( ".fragmented" ), function(elem0) {
        var elem = (/^H\d$/.test(elem0.nodeName) ? elem0.parentNode : elem0);
        [].forEach.call(elem.children, function(item) {
          if (item==elem0) return;
          if (item && !/\bfragment(ed)?\b/.test(item.className) && item.nodeType===1) {
            item.className = item.className + " fragment";
          }
        });
      });
    }
    function revealQuotedList(listType) {
      //compatibility with Rmarkdown slides
      [].forEach.call( document.querySelectorAll("blockquote>" + listType), function(ul) {
        if (!/\bfragmented\b/.test(ul.className)) {
          ul.className = ul.className + " fragmented";
        }        
        var quote = ul.parentNode;
        if (quote.childElementCount===1) {
          quote.parentNode.replaceChild(ul,quote);
        }
      });
    }
    function revealBuildToFragmented() {
      [].forEach.call(document.querySelectorAll( ".build" ), function(elem) {
        if (elem && !/\bfragmented\b/.test(elem.className) && elem.nodeType===1) {
          elem.className = elem.className + " fragmented";
        }
      });
    }
    function revealDivNotesToAside() {
      [].forEach.call(document.querySelectorAll("div.notes"), function(elem) {
        var aside = document.createElement("ASIDE");
        if (elem.id) aside.id = elem.id;
        aside.className = elem.className;
        [].forEach.call(elem.attributes, function(attr) {
          aside.setAttribute( attr.name, attr.value );
        });
        aside.innerHTML = elem.innerHTML;
        elem.parentNode.replaceChild(aside,elem);
      });
    }
    function revealDataQuery() {
      var reveal = document.querySelector(".reveal");
      if (!reveal) return;
      window.location.search.replace(/\bdata-(\w+)(?:=(\w+))?\b/g, function(matched,key,value) {
        reveal.setAttribute("data-" + key, (value ? value : ""));
        return matched;
      });
    }
    function revealRemoveLong() {
      if (/\bpreview(?![\w\-])/.test(document.body.className)) return;
      var reveal = document.querySelector(".reveal");
      if (!reveal) return;
      var value = reveal.hasAttribute("data-long") ? reveal.getAttribute("data-long") : null;
      if (value==null || value=="false" || value=="0") {
        [].forEach.call( document.querySelectorAll("section[data-long]"), function(elem) {
          elem.parentNode.removeChild(elem);
        });
      }
    }
    revealConfig.onLoad = function() {
      revealConfig.getEmbeddedImages();
      revealDataQuery();
      revealRemoveLong();
      revealQuotedList("ul");
      revealQuotedList("ol");
      revealBuildToFragmented();
      revealDivNotesToAside();
      revealAddFragments();
    };
    document.addEventListener("load",revealConfig.onLoad);    
    document.addEventListener("DOMContentLoaded", function() {
      if (typeof Reveal !== "undefined" && !Reveal.isReady()) {
        revealConfig.onLoad();
        Reveal.initialize(revealConfig);
      }
    });    
    revealConfig.initPrint = function() {
      var cssLink = null;
      var bodyClass = null;
      var cap = window.location.search.match(/\bprint-(\w+)\b/);
      if (cap) {
        bodyClass = cap[0];
        cssLink = "https://cdn.jsdelivr.net/reveal.js/2.6.2/css/print/" + cap[1] + ".css";
      }
      if (cssLink) {
        var link  = document.createElement( "link" );
        link.rel  = "stylesheet";
        link.type = "text/css";
        link.href = cssLink;
        var head = document.getElementsByTagName( 'head' )[0];
        if (head) head.appendChild( link );
      }
      if (bodyClass) {
        document.body.className = document.body.className + " " + bodyClass;
      }
    };
    revealConfig.getEmbeddedImages = function() {
      var images = {};
      [].forEach.call( document.querySelectorAll("img[data-linkid]"), function(img) {
        var linkid = img.getAttribute("data-linkid");
        if (linkid) images["/" + linkid] = img.src;
        var path = img.getAttribute("data-path");
        if (path) images["/" + path] = img.src;
      });     
      [].forEach.call( document.querySelectorAll("section"), function(slide) {
        var attrName = "data-background";
        var image = slide.getAttribute(attrName);
        if (!image) {
          attrName = "data-background-image";
          image = slide.getAttribute(attrName);
        }
        if (!image) return;
        var cap = /^\s*!?\[([^\]]+)\]\s*$/.exec(image);
        var href = images["/" + (cap ? cap[1] : image)];
        if (!href) return;
        if (attrName==="data-background" && /^data:/.test(href)) href = "url(" + href + ")";
        slide.setAttribute(attrName, href);
      });
    };    