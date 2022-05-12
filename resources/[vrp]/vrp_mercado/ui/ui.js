let carrinho = []
let produtoID = null

function CloseMercado() {
    $("#wrapper").fadeOut();
    $("#grid").html('');
    $(".container-itens").html('');
    $('#cart').html('');
    $("#checkout").hide();
    carrinho = [];
    $.post('http://vrp_mercado/fechar', JSON.stringify({}));
    $('body').css('background-color', 'transparent')
    $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
}

$(document).keyup(function(e) {
    if (e.key === "Escape") {
        CloseMercado()
    }
});

class CriarProdutos {
    constructor(nome, preco) {
        this.produto = {}
        this.nome = nome
        this.preco = preco
    }

    addCarrinho = () => {
        return carrinho.push({ nome: this.nome, preco: this.preco })
    }

    valorTotal = () => {
        let result = carrinho.map(a => a.preco).reduce((a, b) => {
            return parseInt(a) + parseInt(b);
        });
        return result
    }

    nomeProdutos = () => {
        return carrinho.map(a => a.nome)
    }

}

$(document).ready(function() {

    $("#wrapper").on('click', '#comprar', function() {
        CloseMercado()
        $.post('http://vrp_mercado/comprar', JSON.stringify({ loja: $(this).data('loja'), id: $(this).data('id') }));
    });

    $("#wrapper").on('click', '#enviar', function() {
        let produtoE = $('#estoque');
        let produtoP = $('#valor');
        let produtoF = $('#foto');
        $('.container-itens').html('')
        $.post('http://vrp_mercado/anunciar', JSON.stringify({ loja: $('.nome_loja').html(), produto: produtoID, preco: produtoP.val(), estoque: produtoE.val(), foto: produtoF.val() }));
        CloseMercado()
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        let inventario = data.inventario
        let produtos = data.produtos

        function addComma(num) {
            return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.')
        }

        if (data.dono) {
            $('#header').fadeIn();
            $("#wrapper").fadeIn();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)');
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));


            for (let inv in inventario) {
                $('.container-itens').append(`
                    <div class="item">
                        <span><i class="fas fa-archive"></i> ${inventario[inv].name} <span id="bola">${inventario[inv].amount}</span></span>
                    </div>
                    
                `)

            };

            let $itemi = $('.item').click(function(e) {
                e.preventDefault();
                $itemi.css('border', '1px solid #ddd');
                $itemi.css('color', '#ddd');
                $(this).css('border', '1px solid #07f51a');
                $(this).css('color', '#07f51a');
            });

            for (let item in produtos) {
                $("#grid").append(`
                    <div class="product">
                        <div class="info-large">
                            <h4>${produtos[item].modelo}</h4>
                            <div class="sku">
                                DONO ID: <strong>1</strong>
                            </div>
                            
                            <div class="price-big">
                                <span id="price">$43</span> $${addComma(produtos[item].preco)}
                            </div>
                            
                            <h3>Vendedor</h3>
                            <div class="colors-large">
                                <ul>
                                    <li><span>Cidade de NL</span></li>
                                </ul> 
                            </div>
                
                            <h3>Quantidade</h3>
                            <div class="sizes-large">
                                <span>${produtos[item].quantidade} Disponiveis</span>
                            </div>                   
                                        
                        </div>
                        <div class="make3D">
                            <div class="product-front">
                                <div class="shadow"></div>
                                <img src="icons/${item}.png" alt="" />
                                <div class="image_overlay"></div>
                                <div class="add_to_cart">Comprar</div>       
                                <div class="stats">        	
                                    <div class="stats-container">
                                        <span class="product_price">$${addComma(produtos[item].preco)}</span>
                                        <span class="product_name">Nome</span>    
                                        <span class="product_model" style="opacity: 0;position:absolute">${produtos[item].modelo}</span>
                                        <span class="nome_loja" style="opacity: 0;position:absolute">${produtos[item].nomeLoja}</span>
                                        <p class="product_nameItem">${produtos[item].nomeProduto}</p>                                            
                                        
                                        <div class="product-options">
                                        <strong>Quantidade</strong>
                                        <span>${produtos[item].quantidade}</span>
                                        <strong>Vendedor</strong>
                                        <div class="colors">
                                            <div><span>Cidade de NL</span></div>
                                        </div>
                                    </div>                       
                                    </div>                         
                                </div>
                            </div>
                            
                            <div class="product-back">
                                <div class="shadow"></div>
                            </div>	  
                        </div>	
                    </div>   
                `);
            }
            $(".largeGrid").click(function() {
                $(this).find('a').addClass('active');
                $('.smallGrid a').removeClass('active');

                $('.product').addClass('large').each(function() {});
                setTimeout(function() {
                    $('.info-large').show();
                }, 200);

                return false;
            });

            $(".smallGrid").click(function() {
                $(this).find('a').addClass('active');
                $('.largeGrid a').removeClass('active');

                $('div.product').removeClass('large');
                $(".make3D").removeClass('animate');
                $('.info-large').fadeOut("fast");
                setTimeout(function() {
                    $('div.flip-back').trigger("click");
                }, 400);
                return false;
            });

            $(".smallGrid").click(function() {
                $('.product').removeClass('large');
                return false;
            });

            $('.colors-large a').click(function() {
                return false;
            });


            $('.product').each(function(i, el) {

                $(el).find('.make3D').hover(function() {
                    $(this).parent().css('z-index', "20");
                    $(this).addClass('animate');
                    $(this).find('div.carouselNext, div.carouselPrev').addClass('visible');
                }, function() {
                    $(this).removeClass('animate');
                    $(this).parent().css('z-index', "1");
                    $(this).find('div.carouselNext, div.carouselPrev').removeClass('visible');
                });

            });

            $('.add-cart-large').each(function(i, el) {
                $(el).click(function() {
                    let carousel = $(this).parent().parent().find(".carousel-container");
                    let img = carousel.find('img').eq(carousel.attr("rel"))[0];
                    let position = $(img).offset();

                    let productName = $(this).parent().find('h4').get(0).innerHTML;
                    let productPrice = $('#price').get(0).innerHTML;

                    $("body").append('<div class="floating-cart"></div>');
                    let cart = $('div.floating-cart');
                    $("<img src='" + img.src + "' class='floating-image-large' />").appendTo(cart);

                    $(cart).css({
                        'top': position.top + 'px',
                        "left": position.left + 'px'
                    }).fadeIn("slow").addClass('moveToCart');
                    setTimeout(function() {
                        $("body").addClass("MakeFloatingCart");
                    }, 800);

                    setTimeout(function() {
                        $('div.floating-cart').remove();
                        $("body").removeClass("MakeFloatingCart");


                        let cartItem = "<div class='cart-item'><div class='img-wrap'><img src='" + img.src + "' alt='' /></div><span>" + productName + "</span><strong>$" + productPrice + "</strong><div class='cart-item-border'></div><div class='delete-item'></div></div>";

                        $("#cart .empty").hide();
                        $("#cart").append(cartItem);
                        $("#checkout").fadeIn(500);

                        $("#cart .cart-item").last()
                            .addClass("flash")
                            .find(".delete-item").click(function() {
                                $(this).parent().fadeOut(300, function() {
                                    $(this).remove();
                                    if ($("#cart .cart-item").size() == 0) {
                                        $("#cart .empty").fadeIn(500);
                                        $("#checkout").fadeOut(500);
                                    }
                                })
                            });
                        setTimeout(function() {
                            $("#cart .cart-item").last().removeClass("flash");
                        }, 10);

                    }, 1000);


                });
            })


            $('.sizes a span, .categories a span').each(function(i, el) {
                $(el).append('<span class="x"></span><span class="y"></span>');

                $(el).parent().on('click', function() {
                    if ($(this).hasClass('checked')) {
                        $(el).find('.y').removeClass('animate');
                        setTimeout(function() {
                            $(el).find('.x').removeClass('animate');
                        }, 50);
                        $(this).removeClass('checked');
                        return false;
                    }

                    $(el).find('.x').addClass('animate');
                    setTimeout(function() {
                        $(el).find('.y').addClass('animate');
                    }, 100);
                    $(this).addClass('checked');
                    return false;
                });
            });

            $('.add_to_cart').click(function() {
                let productCard = $(this).parent();
                let position = productCard.offset();
                let productImage = $(productCard).find('img').get(0).src;
                let nomeLoja = $(productCard).find('.nome_loja').get(0).innerHTML;
                let productName = $(productCard).find('.product_nameItem').get(0).innerHTML;
                
                let productModel = $(productCard).find('.product_model').get(0).innerHTML;
                let productPrice = $(productCard).find('.product_price').get(0).innerHTML;

                $( ".addCartbutton").html('');

                $("body").append('<div class="floating-cart"></div>');
                let cart = $('div.floating-cart');
                productCard.clone().appendTo(cart);
                $(cart).css({
                    "top": position.top + "px",
                    "left": position.left + "px"
                }).fadeIn("slow").addClass("moveToCart");
                setTimeout(function() {
                    $("body").addClass("MakeFloatingCart");
                }, 800);
                setTimeout(function() {
                    $("div.floating-cart").remove();
                    $("body").removeClass("MakeFloatingCart");


                    let cartItem = "<div class='cart-item'><div class='img-wrap'><img src='" + productImage + "' alt='' /></div><span>" + productName + "</span><strong>" + productPrice + "</strong><div class='cart-item-border'></div><div class='delete-item'></div></div>";
                    $( ".addCartbutton").html('');
                    $("#cart .empty").hide();
                    $("#cart").append(cartItem);

                    const produto = new CriarProdutos(productModel, productPrice)
                    produto.addCarrinho()

                    $(".addCartbutton").delay( 800 ).append(`
                        <div id="checkout">
                            <button id="comprar" data-id="${produto.nomeProdutos()}" data-loja="${nomeLoja}">Comprar</button>
                        </div>
                    `);

                    $("#cart .cart-item").last()
                        .addClass("flash")
                        .find(".delete-item").click(function() {
                            $(this).parent().fadeOut(300, function() {
                                $(this).remove();
                                if ($("#cart .cart-item").size() == 0) {
                                    $("#cart .empty").fadeIn(500);
                                    $("#checkout").fadeOut(500);
                                }
                            })
                        });
                    setTimeout(function() {
                        $("#cart .cart-item").last().removeClass("flash");
                    }, 10);

                }, 1000);

            });

        } else {

            $("#wrapper").fadeIn();
            $('#header').fadeOut();
            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')

            for (let item in produtos) {
                $("#grid").append(`
				<div class="product">
                <div class="info-large">
                    <h4>${produtos[item].modelo}</h4>
                    <div class="sku">
                        DONO ID: <strong>1</strong>
                    </div>
                     
                    <div class="price-big">
                        <span id="price">$43</span> $${addComma(produtos[item].preco)}
                    </div>
                     
                    <h3>Vendedor</h3>
                    <div class="colors-large">
                        <ul>
                            <li><span>Cidade de NL</span></li>
                        </ul> 
                    </div>
        
                    <h3>Quantidade</h3>
                    <div class="sizes-large">
                        <span>${produtos[item].quantidade} Disponiveis</span>
                    </div>                   
                                 
                </div>
                <div class="make3D">
                    <div class="product-front">
                        <div class="shadow"></div>
                        <img src="icons/${item}.png" alt="" />
                        <div class="image_overlay"></div>
                        <div class="add_to_cart">Comprar</div>       
                        <div class="stats">        	
                            <div class="stats-container">
                                <span class="product_price">${addComma(produtos[item].preco)}</span>
                                <span class="product_name">Nome</span>    
                                <span class="product_model" style="opacity: 0;position:absolute">${produtos[item].modelo}</span>
                                <span class="nome_loja" style="opacity: 0;position:absolute">${produtos[item].nomeLoja}</span>
                                <p class="product_nameItem">${produtos[item].nomeProduto}</p>                                            
                                
                                <div class="product-options">
                                <strong>Quantidade</strong>
                                <span>${produtos[item].quantidade}</span>
                            </div>                       
                            </div>                         
                        </div>
                    </div>
                    
                    <div class="product-back">
                        <div class="shadow"></div>
                    </div>	  
                </div>	
            </div>   
                `);
            }

            $(".largeGrid").click(function() {
                $(this).find('a').addClass('active');
                $('.smallGrid a').removeClass('active');

                $('.product').addClass('large').each(function() {});
                setTimeout(function() {
                    $('.info-large').show();
                }, 200);

                return false;
            });

            $(".smallGrid").click(function() {
                $(this).find('a').addClass('active');
                $('.largeGrid a').removeClass('active');

                $('div.product').removeClass('large');
                $(".make3D").removeClass('animate');
                $('.info-large').fadeOut("fast");
                setTimeout(function() {
                    $('div.flip-back').trigger("click");
                }, 400);
                return false;
            });

            $(".smallGrid").click(function() {
                $('.product').removeClass('large');
                return false;
            });

            $('.colors-large a').click(function() {
                return false;
            });


            $('.product').each(function(i, el) {

                $(el).find('.make3D').hover(function() {
                    $(this).parent().css('z-index', "20");
                    $(this).addClass('animate');
                    $(this).find('div.carouselNext, div.carouselPrev').addClass('visible');
                }, function() {
                    $(this).removeClass('animate');
                    $(this).parent().css('z-index', "1");
                    $(this).find('div.carouselNext, div.carouselPrev').removeClass('visible');
                });

            });

            $('.add-cart-large').each(function(i, el) {
                $(el).click(function() {
                    let carousel = $(this).parent().parent().find(".carousel-container");
                    let img = carousel.find('img').eq(carousel.attr("rel"))[0];
                    let position = $(img).offset();

                    let productName = $(this).parent().find('h4').get(0).innerHTML;
                    let productPrice = $('#price').get(0).innerHTML;

                    $("body").append('<div class="floating-cart"></div>');
                    let cart = $('div.floating-cart');
                    $("<img src='" + img.src + "' class='floating-image-large' />").appendTo(cart);

                    $(cart).css({
                        'top': position.top + 'px',
                        "left": position.left + 'px'
                    }).fadeIn("slow").addClass('moveToCart');
                    setTimeout(function() {
                        $("body").addClass("MakeFloatingCart");
                    }, 800);

                    setTimeout(function() {
                        $('div.floating-cart').remove();
                        $("body").removeClass("MakeFloatingCart");


                        let cartItem = "<div class='cart-item'><div class='img-wrap'><img src='" + img.src + "' alt='' /></div><span>" + productName + "</span><strong>$" + productPrice + "</strong><div class='cart-item-border'></div><div class='delete-item'></div></div>";

                        $("#cart .empty").hide();
                        $("#cart").append(cartItem);
                        $("#checkout").fadeIn(500);

                        $("#cart .cart-item").last()
                            .addClass("flash")
                            .find(".delete-item").click(function() {
                                $(this).parent().fadeOut(300, function() {
                                    $(this).remove();
                                    if ($("#cart .cart-item").size() == 0) {
                                        $("#cart .empty").fadeIn(500);
                                        $("#checkout").fadeOut(500);
                                    }
                                })
                            });
                        setTimeout(function() {
                            $("#cart .cart-item").last().removeClass("flash");
                        }, 10);

                    }, 1000);


                });
            })


            $('.sizes a span, .categories a span').each(function(i, el) {
                $(el).append('<span class="x"></span><span class="y"></span>');

                $(el).parent().on('click', function() {
                    if ($(this).hasClass('checked')) {
                        $(el).find('.y').removeClass('animate');
                        setTimeout(function() {
                            $(el).find('.x').removeClass('animate');
                        }, 50);
                        $(this).removeClass('checked');
                        return false;
                    }

                    $(el).find('.x').addClass('animate');
                    setTimeout(function() {
                        $(el).find('.y').addClass('animate');
                    }, 100);
                    $(this).addClass('checked');
                    return false;
                });
            });

            $('.add_to_cart').click(function() {
                let productCard = $(this).parent();
                let position = productCard.offset();
                let productImage = $(productCard).find('img').get(0).src;
                let nomeLoja = $(productCard).find('.nome_loja').get(0).innerHTML;
                let productName = $(productCard).find('.product_nameItem').get(0).innerHTML;
                let productModel = $(productCard).find('.product_model').get(0).innerHTML;
                let productPrice = $(productCard).find('.product_price').get(0).innerHTML;

                $('.addCartbutton').html('')

                $("body").append('<div class="floating-cart"></div>');
                let cart = $('div.floating-cart');
                productCard.clone().appendTo(cart);
                $(cart).css({
                    "top": position.top + "px",
                    "left": position.left + "px"
                }).fadeIn("slow").addClass("moveToCart");
                setTimeout(function() {
                    $("body").addClass("MakeFloatingCart");
                }, 800);
                setTimeout(function() {
                    $("div.floating-cart").remove();
                    $("body").removeClass("MakeFloatingCart");


                    let cartItem = "<div class='cart-item'><div class='img-wrap'><img src='" + productImage + "' alt='' /></div><span>" + productName + "</span><strong>" + productPrice + "</strong><div class='cart-item-border'></div><div class='delete-item'></div></div>";
                    $( ".addCartbutton").html('');
                    $("#cart .empty").hide();
                    $("#cart").append(cartItem);

                    const produto = new CriarProdutos(productModel, productPrice)
                    produto.addCarrinho()

                    $(".addCartbutton").delay( 800 ).append(`
                        <div id="checkout">
                            <button id="comprar" data-id="${produto.nomeProdutos()}" data-loja="${nomeLoja}">Comprar</button>
                        </div>
                    `);

                    $("#cart .cart-item").last()
                        .addClass("flash")
                        .find(".delete-item").click(function() {
                            $(this).parent().fadeOut(300, function() {
                                $(this).remove();
                                if ($("#cart .cart-item").size() == 0) {
                                    $("#cart .empty").fadeIn(500);
                                    $("#checkout").fadeOut(500);
                                }
                            })
                        });
                    setTimeout(function() {
                        $("#cart .cart-item").last().removeClass("flash");
                    }, 10);

                }, 1000);

            });
        }

    })
});



function AnuncioChange() {
    $("#grid").fadeOut();
    $('#grid-menu').fadeOut();
    $('#gridA').fadeIn();
    $("#grid-anuncio").fadeIn();
}

function ReturnMercado() {
    $("#grid").fadeIn();
    $('#grid-menu').fadeIn();
    $('#gridA').fadeOut();
    $("#grid-anuncio").fadeOut();
}