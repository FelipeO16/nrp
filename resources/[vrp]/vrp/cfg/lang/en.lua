
-- define all language properties

local lang = {
  common = {
    welcome = "Welcome. Use the phone keys to use the menu. last login: {1}",
    no_player_near = "Nenhum jogador perto de você.",
    invalid_value = "Valor invalido.",
    invalid_name = "Nome invalido.",
    not_found = "Não encontrado.",
    request_refused = "Pedido recusado.",
    wearing_uniform = "Tenha cuidado, você está vestindo um uniforme.",
    not_allowed = "Não permitido."
  },
  weapon = {
    pistol = "Pistola"
  },
  survival = {
    starving = "morrendo de fome",
    thirsty =  "morrendo de sede"
  },
  money = {
    display = "{1}",
    given = "Enviou {1}$.",
    received = "Recebeu {1}$.",
    not_enough = "Dinheiro insuficiente.",
    paid = "Pagou {1}$.",
    give = {
      title = "Enviar Dinheiro",
      description = "Dê dinheiro ao jogador mais próximo.",
      prompt = "Quantidade a dar:"
    }
  },
  inventory = {
    title = "Inventario",
    description = "Abrir inventario.",
    iteminfo = "({1})<br /><br />{2}<br /><em>{3} kg</em>",
    info_weight = "peso {1}/{2} kg",
    give = {
      title = "Adicionar",
      description = "Dê itens para o jogador mais próximo.",
      prompt = "Quantidade (max {1}):",
      given = "Enviou {1} {2}.",
      received = "Recebeu {1} {2}.",
    },
    trash = {
      title = "Dropar",
      description = "Dropar item do inventario.",
      prompt = "Quantidade (max {1}):",
      done = "Item dropado {1} {2}."
    },
    missing = "Ausência de {2} {1}.",
    full = "Inventario Cheio.",
    chest = {
      title = "Bau",
      already_opened = "Este baú já está aberto por outra pessoa.",
      full = "Chest full.",
      take = {
        title = "Pegar",
        prompt = "Quantidade a levar (max {1}):"
      },
      put = {
        title = "Put",
        prompt = "Quantidade para colocar (max {1}):"
      }
    }
  },
  atm = {
    title = "ATM",
    info = {
      title = "Info",
      bank = "banco: {1} R$"
    },
    deposit = {
      title = "Depositar",
      description = "carteira para banco",
      prompt = "Insira a quantia de dinheiro para depósito:",
      deposited = "{1}$ depositado."
    },
    withdraw = {
      title = "Sacar",
      description = "banco para carteira",
      prompt = "Insira a quantia de dinheiro para sacar:",
      withdrawn = "{1}$ Retirado.",
      not_enough = "Você não tem dinheiro suficiente no banco."
    }
  },
  business = {
    title = "Câmara do Comércio",
    directory = {
      title = "Directory",
      description = "Business directory.",
      dprev = "> Prev",
      dnext = "> Next",
      info = "<em>capital: </em>{1} $<br /><em>owner: </em>{2} {3}<br /><em>registration n°: </em>{4}<br /><em>phone: </em>{5}"
    },
    info = {
      title = "Business info",
      info = "<em>name: </em>{1}<br /><em>capital: </em>{2} $<br /><em>capital transfer: </em>{3} $<br /><br/>Capital transfer is the amount of money transfered for a business economic period, the maximum is the business capital."
    },
    addcapital = {
      title = "Add capital",
      description = "Add capital to your business.",
      prompt = "Amount to add to the business capital:",
      added = "{1}$ added to the business capital."
    },
    launder = {
      title = "Money laundering",
      description = "Use your business to launder dirty money.",
      prompt = "Amount of dirty money to launder (max {1} $): ",
      laundered = "{1}$ laundered.",
      not_enough = "Not enough dirty money."
    },
    open = {
      title = "Abrir Negócio",
      description = "Abra o seu negócio, o capital mínimo é {1} R$.",
      prompt_name = "Nome da empresa (não pode mudar depois, no máximo {1} chars):",
      prompt_capital = "Inicial da Capital (min {1})",
      created = "Negócio criado."
      
    }
  },
  cityhall = {
    title = "Prefeitura",
    identity = {
      title = "Nova Identidade",
      description = "Crie uma nova identidade, custo = {1} R$.",
      prompt_firstname = "Digite seu primeiro nome:",
      prompt_name = "Digite seu nome:",
      prompt_age = "Digite sua idade:",
    },
    menu = {
      title = "Identidade",
      info = "<em>Nome: </em>{1}<br /><em>Sobrenome: </em>{2}<br /><em>Idade: </em>{3}<br /><em>N° registrado: </em>{4}<br /><em>Numero: </em>{5}<br /><em>Endereço: </em>{7}, {6}"
    }
  },
  police = {
    title = "Policia",
    wanted = "Rank de procurado {1}",
    not_handcuffed = "Não algemado",
    cloakroom = {
      title = "Armario",
      uniform = {
        title = "Uniforme",
        description = "Colocar uniforme."
      }
    },
    pc = {
      title = "PC",
      searchreg = {
        title = "Pesquisar Registro",
        description = "Procure identidade por registro.",
        prompt = "Digite o número de registro:"
      },
      closebusiness = {
        title = "Fechar negócios",
        description = "Fechar negócios do jogador mais próximo.",
        request = "Você tem certeza de fechar o negócio {3} criado por {1} {2} ?",
        closed = "Negócio fechado!."
      },
      trackveh = {
        title = "Rastrear veículo",
        description = "Rastrear um veículo pelo seu número de registro.",
        prompt_reg = "Digite o número de registro:",
        prompt_note = "Insira uma nota / razão de rastreamento:",
        tracking = "Rastreamento iniciado.",
        track_failed = "Rastreamento de {1} ({2})  falhou!",
        tracked = "Rastreado {1} ({2})"
      },
      records = {
        show = {
          title = "Mostrar registros",
          description = "Mostrar registros policiais por número de registro."
        },
        delete = {
          title = "Limpar Registros",
          description = "Limpar registro pelo numero de registro.",
          deleted = "Registros Apagados"
        }
      }
    },
    menu = {
      handcuff = {
        title = "Algemar",
        description = "Colocar/Retirar algemas do jogador."
      },
      drag = {
        title = "Arrastar",
        description = "Arrastar jogador por perto."
      },
      putinveh = {
        title = "Colocar no veiculo",
        description = "Colocar jogador proximo dentro do veiculo."
      },
      getoutveh = {
        title = "Tirar do veiculo",
        description = "Pegar jogador no veiculo."
      },
      askid = {
        title = "Pedir ID",
        description = "Pedir ID do jogador mais proximo.",
        request = "Você quer dar seu cartão de identificação ?",
        request_hide = "Ocultar o cartão de identificação.",
        asked = "Pedindo..."
      },
      check = {
        title = "Revistar",
        description = "Revistar jogador mais perto.",
        request_hide = "Ocultar o relatório de verificação.",
        info = "<em>Dinheiro: </em>{1} $<br /><br /><em>Inventario: </em>{2}<br /><br /><em>Armas: </em>{3}",
        checked = "Você está sendo verificado."
      },
      seize = {
        seized = "Aprender {2} {1}",
        weapons = {
          title = "Apreender Armas",
          description = "Aprender Armas do jogador proximo",
          seized = "Suas armas foram apreendidas."
        },
        items = {
          title = "Aprender Itens",
          description = "Apreender itens ilegais",
          seized = "Seus itens ilegais foram apreendidos."
        }
      },
      jail = {
        title = "Cadeia",
        description = "Prender/soltar prender jogador proximo.",
        not_found = "Nenhuma cadeia encontrada.",
        jailed = "Preso.",
        unjailed = "Solto.",
        notify_jailed = "Você foi preso.",
        notify_unjailed = "Você foi solto."
      },
      fine = {
        title = "Fine",
        description = "Fine the nearest player.",
        fined = "Fined {2} $ for {1}.",
        notify_fined = "You have been fined  {2} $ for {1}.",
        record = "[Fine] {2} $ for {1}"
      },
      store_weapons = {
        title = "Guardar Armas",
        description = "colocar armas no inventario."
      }
    },
    identity = {
      info = "<em>Nome: </em>{1}<br /><em>Sobrenome: </em>{2}<br /><em>Idade: </em>{3}<br /><em>N° registro: </em>{4}<br /><em>Celular: </em>{5}<br /><em>Negócios: </em>{6}<br /><em>Empresa: </em>{7} $<br /><em>Endereço: </em>{9}, {8}"
    }
  },
  emergency = {
    menu = {
      revive = {
        title = "Reanimar",
        description = "reanimar jogador proximo.",
        not_in_coma = "não está em coma."
      }
    }
  },
  phone = {
    title = "Celular",
    directory = {
      title = "Diretório",
      description = "Abra o diretório do telefone.",
      add = {
        title = "> Add",
        prompt_number = "Digite o número de telefone para adicionar:",
        prompt_name = "Digite o nome da entrada:",
        added = "Entrada adicionada."
      },
      sendsms = {
        title = "Enviar SMS",
        prompt = "Mensagem (max {1} chars):",
        sent = "Enviada para n°{1}.",
        not_sent = " n°{1} indisponível."
      },
      sendpos = {
        title = "Enviar Posições",
      },
      remove = {
        title = "Remover"
      },
      call = {
        title = "Ligar",
        not_reached = " n°{1} não encontrado."
      }
    },
    sms = {
      title = "Historico SMS",
      description = "Historico SMS Recebido.",
      info = "<em>{1}</em><br /><br />{2}",
      notify = "SMS {1}:  {2}"
    },
    smspos = {
      notify = "SMS POSIÇÃO  {1}"
    },
    service = {
      title = "Serviço",
      description = "Ligue para um serviço ou um número de emergência.",
      prompt = "Se necessário, insira uma mensagem para o serviço:",
      ask_call = "Recebida {1} ligação, você aceita ? <em>{2}</em>",
      taken = "Esta chamada já foi feita."
    },
    announce = {
      title = "Anuncio",
      description = "Poste um anúncio visível para todos por alguns segundos.",
      item_desc = "{1} $<br /><br/>{2}",
      prompt = "Anunciar conteúdo (10-1000 chars): "
    },
    call = {
      ask = "Aceitar chamada de {1} ?",
      notify_to = "Chamando {1}...",
      notify_from = "Receber chamada de  {1}...",
      notify_refused = "ligação para  {1}...  recusada."
    },
    hangup = {
      title = "Desligar",
      description = "Desligue o telefone (desligamento da chamada atual)."
    }
  },
  emotes = {
    title = "Animações",
    clear = {
      title = "> Parar",
      description = "Limpar Animações."
    }
  },
  home = {
    buy = {
      title = "Comprar",
      description = "Compre uma casa aqui, o preço é {1} R$.",
      bought = "comprada!.",
      full = "O lugar está cheio.",
      have_home = "Você já tem uma casa."
    },
    sell = {
      title = "Vender",
      description = "Venda sua casa por {1} $",
      sold = "Vendida.",
      no_home = "Você não tem casa aqui."
    },
    intercom = {
      title = "Interfone",
      description = "Use o interfone para entrar em uma casa.",
      prompt = "Numero:",
      not_available = "Inexistente.",
      refused = "Entrada Recusada.",
      prompt_who = "Diga quem você é:",
      asked = "Tocando...",
      request = "Alguém quer abrir a porta da sua casa: <em>{1}</em>"
    },
    slot = {
      leave = {
        title = "Sair"
      },
      ejectall = {
        title = "Expulsar todos",
        description = "Ejete todos os visitantes da casa, inclusive você, e feche a casa."
      }
    },
    wardrobe = {
      title = "Guarda roupa",
      save = {
        title = "Salvar",
        prompt = "Nome Save:"
      }
    },
    gametable = {
      title = "Mesa de jogo",
      bet = {
        title = "Comece a apostar",
        description = "Comece uma aposta com jogadores perto de você, o vencedor será selecionado aleatoriamente.",
        prompt = "Valor da aposta:",
        request = "[IB] Você quer apostar {1} $ ?",
        started = "Aposta iniciada!"
      }
    },
    radio = {
      title = "Radio",
      off = {
        title = "> desligar off"
      }
    }
  },
  garage = {
    title = "Garagem ({1})",
    owned = {
      title = "Dono",
      description = "Veículos próprios."
    },
    buy = {
      title = "Comprar",
      description = "Comprar veiculo.",
      info = "{1} $<br /><br />{2}"
    },
    sell = {
      title = "Vender",
      description = "Vender Veiculos."
    },
    rent = {
      title = "Aluguel",
      description = "Alugue um veículo para a sessão (até você desconectar)."
    },
    store = {
      title = "Loja",
      description = "Coloque seu veículo atual na garagem.",
      too_far = "O veículo está muito longe.",
      wrong_garage = "O veículo não pode ser armazenado nesta garagem."
    }
  },
  vehicle = {
    title = "Veiculo",
    no_owned_near = "Nenhum veículo seu por perto.",
    trunk = {
      title = "Capu",
      description = "Abrir o capu do carro."
    },
    detach_trailer = {
      title = "Destacar trailer",
      description = "Destacar trailer."
    },
    detach_towtruck = {
      title = "Destacar o caminhão de reboque",
      description = "Destacar o caminhão de reboque."
    },
    detach_cargobob = {
      title = "Retire Cargobob",
      description = "Retire Cargobob."
    },
    lock = {
      title = "Trancar/destrancar",
      description = "Trancar ou Destrancar o veículo."
    },
    engine = {
      title = "Motor on/off",
      description = "Ligar e desligar motor."
    },
    asktrunk = {
      title = "Peça para abrir o capu",
      asked = "Pedindo...",
      request = "Você quer abrir o porta-malas?"
    },
    replace = {
      title = "Substituir veículo",
      description = "Substitua no chão o veículo mais próximo."
    },
    repair = {
      title = "Reparar Veiculo",
      description = "Reparar o veículo mais próximo."
    }
  },
  gunshop = {
    title = "Loja de Arma ({1})",
    prompt_ammo = "Quantidade de munição para comprar para a {1}:",
    info = "<em>corpo: </em> {1} $<br /><em>munição: </em> {2} $/u<br /><br />{3}"
  },
  market = {
    title = "Mercado ({1})",
    prompt = "Quantidade de {1} para comprar:",
    info = "{1} $<br /><br />{2}"
  },
  skinshop = {
    title = "Loja de Roupa"
  },
  cloakroom = {
    title = "Armario ({1})",
    undress = {
      title = "> Despir"
    }
  },
  itemtr = {
    not_enough_reagents = "Reagentes insuficientes.",
    informer = {
      title = "Informação Ilegal",
      description = "{1} R$",
      bought = "Posição enviada para o seu GPS."
    }
  },
  mission = {
    blip = "Missão ({1}) {2}/{3}",
    display = "<span class=\"name\">{1}</span> <span class=\"step\">{2}/{3}</span><br /><br />{4}",
    cancel = {
      title = "Cancelar Missão"
    }
  },
  aptitude = {
    title = "Skills",
    description = "Mostar Skills.",
    lose_exp = "Skill {1}/{2} -{3} exp.",
    --earn_exp = "Skill {1}/{2} +{3} exp.",
    earn_exp = "[{2}] +{3} exp.",
    level_down = "Skill {1}/{2} nivel rebaixado ({3}).",
    --level_up = "Skill {1}/{2} novo nivel ({3}).",
    level_up = "Você subiu de nivel: {2} ({3}).",
    display = {
      group = "{1}: ",
      aptitude = "{1} LVL {3} EXP {2}"
    }
  },
  radio = {
    title = "Radio ON/OFF"
  }
}

return lang
