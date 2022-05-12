let carrinho = []
let QtdAmmo = 20

function FecharLoja() {
    $("#lojaarma").fadeOut();
    $('body').css('background-color', 'transparent')
    $('#resetItens').html('')
    $('#footerShop').html('')
    $.post('http://vrp_gunshop/fechar', JSON.stringify({}));
    $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }));
}


$(document).keyup(function(e) {
    if (e.key === "Escape") {
        FecharLoja()
    }
});

class CriarCarrinho {
    constructor(nome, ammo) {
		this.nome = nome
		this.ammo = ammo
    }

    addCarrinho = () => {
        return carrinho.push({ nome: this.nome, ammo: this.ammo })
	}
	
    nomeArmas = () => {
        return carrinho.map(a => a.nome)
	}
	
	qtdAmmo = () => {
		return carrinho.map(a => a.ammo)
	}

}

$(document).ready(function() {

    $(".cd-cart__footer").on('click', '#comprar', function() {
        $.post('http://vrp_hud/fechar', JSON.stringify({ id: false }))
        let loja = $(this).data('loja')
        let nome = $(this).data('nome')
        let qtd = $(this).data('qtd')
        $.post('http://vrp_gunshop/comprar', JSON.stringify({ loja: loja, id: nome, quantidade: qtd }));
        FecharLoja()
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.show) {
            let gunshopWeapons = data.armas

            $('body').css('background-color', 'rgba(139, 102, 241, 0.15)')
            $("#lojaarma").fadeIn();
            $.post('http://vrp_hud/fechar', JSON.stringify({ id: true }));

            $('#footerShop').html('')
            for (let item in gunshopWeapons) {
                $("#footerShop").append(`
                    <div class="item-shop">
                    <div class="img">
                        <img src="${gunshopWeapons[item].img}">
                    </div>
                    <div class="info">
                        <p>${gunshopWeapons[item].modelo}</p>
                            <div class="line"></div>
                            <span>${gunshopWeapons[item].descricao}</span>  
                        </div>
                        <div href="#0" class="add-cart-index js-cd-add-to-cart" data-loja="${gunshopWeapons[item].nomeLoja}" data-name="${gunshopWeapons[item].modelo}" data-item="${item}" data-price="${gunshopWeapons[item].preco}"><i class="fas fa-shopping-cart"></i></div>
                    </div>
                `);
            }

            var cart = document.getElementsByClassName('js-cd-cart');
            if(cart.length > 0) {
      
                var cartAddBtns = $('#footerShop .js-cd-add-to-cart'),
                cartBody = cart[0].getElementsByClassName('cd-cart__body')[0],
                cartList = cartBody.getElementsByTagName('ul')[0],
                cartListItems = cartList.getElementsByClassName('cd-cart__product'),
                cartTotal = cart[0].getElementsByClassName('cd-cart__checkout')[0].getElementsByTagName('span')[0],
                cartCount = cart[0].getElementsByClassName('cd-cart__count')[0],
                cartCountItems = cartCount.getElementsByTagName('li'),
                cartUndo = cart[0].getElementsByClassName('cd-cart__undo')[0],
                productId = 0, 
                cartTimeoutId = false,
                animatingQuantity = false;
              initCartEvents();
      
      
              function initCartEvents() {
                  for(var i = 0; i < cartAddBtns.length; i++) {(function(i){
                      cartAddBtns[i].addEventListener('click', addToCart);
                  })(i);}
      
                  cart[0].getElementsByClassName('cd-cart__trigger')[0].addEventListener('click', function(event){
                      event.preventDefault();
                      toggleCart();
                  });
                  
                  cart[0].addEventListener('click', function(event) {
                      if(event.target == cart[0]) { 
                          toggleCart(true);
                      } else if (event.target.closest('.cd-cart__delete-item')) { 
                          event.preventDefault();
                          removeProduct(event.target.closest('.cd-cart__product'));
                      }
                  });
      
                  cart[0].addEventListener('change', function(event) {
                      if(event.target.tagName.toLowerCase() == 'select') quickUpdateCart();
                  });
      
                  cartUndo.addEventListener('click', function(event) {
                      if(event.target.tagName.toLowerCase() == 'a') {
                          event.preventDefault();
                          if(cartTimeoutId) clearInterval(cartTimeoutId);
                          var deletedProduct = cartList.getElementsByClassName('cd-cart__product--deleted')[0];
                          Util.addClass(deletedProduct, 'cd-cart__product--undo');
                          deletedProduct.addEventListener('animationend', function cb(){
                              deletedProduct.removeEventListener('animationend', cb);
                              Util.removeClass(deletedProduct, 'cd-cart__product--deleted cd-cart__product--undo');
                              deletedProduct.removeAttribute('style');
                              quickUpdateCart();
                          });
                          Util.removeClass(cartUndo, 'cd-cart__undo--visible');
                      }
                  });
              };
      
              function addToCart(event) {
                  event.preventDefault();
                  if(animatingQuantity) return;
                  var cartIsEmpty = Util.hasClass(cart[0], 'cd-cart--empty');
      
                  $(".reset option:selected").each(function() {
                      QtdAmmo = $(this).val();
                  }); 			
      
                  addProduct(this);
                  updateCartCount(cartIsEmpty);
      
                  Util.removeClass(cart[0], 'cd-cart--empty');
              };
      
              function toggleCart(bool) { 
                  var cartIsOpen = ( typeof bool === 'undefined' ) ? Util.hasClass(cart[0], 'cd-cart--open') : bool;
              
                  if( cartIsOpen ) {
                      Util.removeClass(cart[0], 'cd-cart--open');
                      if(cartTimeoutId) clearInterval(cartTimeoutId);
                      Util.removeClass(cartUndo, 'cd-cart__undo--visible');
                      removePreviousProduct(); 
      
                      setTimeout(function(){
                          cartBody.scrollTop = 0;
                          if( Number(cartCountItems[0].innerText) == 0) Util.addClass(cart[0], 'cd-cart--empty');
                      }, 500);
                  } else {
                      Util.addClass(cart[0], 'cd-cart--open');
                  }
              };
      
              function addProduct(target) {
                  let price = $(target).attr('data-price');
                  let name = $(target).attr('data-name')
                  let nomeLoja = $(target).attr('data-loja')
                  let modelArma = $(target).attr('data-item')
                  
                  $("#comprar").remove();
      
                  productId = productId + 1;
                  var productAdded = `
                  <li class="cd-cart__product">
                      <div class="cd-cart__image">
                          <a href="#0">
                              <img src="https://ih0.redbubble.net/image.592122995.4360/flat,800x800,070,f.jpg" alt="placeholder">
                          </a>
                      </div>
                      <div class="cd-cart__details">
                          <h3 class="truncate">
                              <a id="modelWeapon" href="#0">`+name+`</a>
                          </h3>
                          <span class="cd-cart__price">`+ price +`</span>
                      <div class="cd-cart__actions">
                          <a href="#0" class="cd-cart__delete-item">Remover</a>
                      <div class="cd-cart__quantity">
                          <label for="cd-product-`+ productId +`">Munição</label>
                          <span class="cd-cart__select">
                          <select class="reset" id="cd-product-`+ productId +`" name="quantity">
                              <option id="ammo1">20</option>
                              <option id="ammo2">40</option>
                              <option id="ammo3">70</option>
                              <option id="ammo4">80</option>
                              <option id="ammo5">90</option>
                              <option id="ammo6">100</option>
                              <option id="ammo7">120</option>
                              <option id="ammo8">200</option>
                              <option id="ammo9">250</option>
                          </select>
                          <svg class="icon" viewBox="0 0 12 12"><polyline fill="none" stroke="currentColor" points="2,4 6,8 10,4 "/></svg></span></div></div></div>
                  </li>`;
      
                  
                  const produto = new CriarCarrinho(modelArma,QtdAmmo)
                  produto.addCarrinho()
      
                  $(".cd-cart__footer").append(`
                      <a id="comprar" data-nome="${produto.nomeArmas()}" data-qtd="${produto.qtdAmmo()}" data-loja="${nomeLoja}" href="#0" class="cd-cart__checkout">
                          <em>Comprar</span>
                              <svg class="icon icon--sm" viewBox="0 0 24 24">
                                  <g fill="none" stroke="currentColor">
                                      <line stroke-width="2" stroke-linecap="round" stroke-linejoin="round" x1="3" y1="12" x2="21" y2="12"/>
                                      <polyline stroke-width="2" stroke-linecap="round" stroke-linejoin="round" points="15,6 21,12 15,18 "/>
                                  </g>
                              </svg>
                          </em>
                      </a>
                  `);
      
                  cartList.insertAdjacentHTML('beforeend', productAdded);
              };
      
              function removeProduct(product) {
                  if(cartTimeoutId) clearInterval(cartTimeoutId);
                  removePreviousProduct(); 
                  
                  var topPosition = product.offsetTop,
                      productQuantity = Number(product.getElementsByTagName('select')[0].value),
                      productTotPrice = Number((product.getElementsByClassName('cd-cart__price')[0].innerText).replace('$', '')) * productQuantity;
      
                  product.style.top = topPosition+'px';
                  Util.addClass(product, 'cd-cart__product--deleted');
      
                  updateCartCount(true, -productQuantity);
                  Util.addClass(cartUndo, 'cd-cart__undo--visible');
      
                  cartTimeoutId = setTimeout(function(){
                      Util.removeClass(cartUndo, 'cd-cart__undo--visible');
                      removePreviousProduct();
                  }, 8000);
              };
      
              function removePreviousProduct() { 
                  var deletedProduct = cartList.getElementsByClassName('cd-cart__product--deleted');
                  if(deletedProduct.length > 0 ) deletedProduct[0].remove();
              };
      
              function updateCartCount(emptyCart, quantity) {
                  if( typeof quantity === 'undefined' ) {
                      var actual = Number(cartCountItems[0].innerText) + 1;
                      var next = actual + 1;
                      
                      if( emptyCart ) {
                          cartCountItems[0].innerText = actual;
                          cartCountItems[1].innerText = next;
                          animatingQuantity = false;
                      } else {
                          Util.addClass(cartCount, 'cd-cart__count--update');
      
                          setTimeout(function() {
                              cartCountItems[0].innerText = actual;
                          }, 150);
      
                          setTimeout(function() {
                              Util.removeClass(cartCount, 'cd-cart__count--update');
                          }, 200);
      
                          setTimeout(function() {
                              cartCountItems[1].innerText = next;
                              animatingQuantity = false;
                          }, 230);
                      }
                  } else {
                      var actual = Number(cartCountItems[0].innerText) + quantity;
                      var next = actual + 1;
                      
                      cartCountItems[0].innerHTML = actual;
                      cartCountItems[1].innerHTML = next;
                      animatingQuantity = false;
                  }
              };
      
              function updateCartTotal(price, bool) {
                  cartTotal.innerText = bool ? (Number(cartTotal.innerText) + Number(price)).toFixed(2) : (Number(cartTotal.innerText) - Number(price)).toFixed(2);
              };
      
              function quickUpdateCart() {
                  var quantity = 0;
                  var price = 0;
      
                  for(var i = 0; i < cartListItems.length; i++) {
                      if( !Util.hasClass(cartListItems[i], 'cd-cart__product--deleted') ) {
                          var singleQuantity = Number(cartListItems[i].getElementsByTagName('select')[0].value);
                          quantity = quantity + singleQuantity;
                          price = price + singleQuantity*Number((cartListItems[i].getElementsByClassName('cd-cart__price')[0].innerText).replace('$', ''));
                      }
                  }
      
                  cartTotal.innerText = price.toFixed(2);
                  cartCountItems[1].innerText = quantity+1;
              };
        }
        }
    })
});