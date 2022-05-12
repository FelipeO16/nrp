
local cfg = {}

cfg.groups = {

  ["admin"] = {
    "adm.perm"
  },
  ["user"] = {
    "player.phone",
    "player.calladmin",
    "police.askid",
    "police.store_weapons",
    "police.seizable"
  },
  ["Mafia"] = {
	"mafia.permissao"
  },
  ["LSPD"] = {
    _config = {
      title = "Police",
      gtype = "job",
      salario = 1500,
      lvl = 1,
      whitelist = true,
      onjoin =  function(player) vRPclient._setCop(player,true) end,
      onspawn = function(player) vRPclient._setCop(player,true) end,
      onleave = function(player) vRPclient._setCop(player,false) end
    },
    "police.menu",
    "police.cloakroom",
    "police.pc",
    "police.handcuff",
    "police.drag",
    "police.putinveh",
    "police.getoutveh",
    "police.check",
    "police.service",
    "police.wanted",
    "police.seize.weapons",
    "police.seize.items",
    "police.jail",
    "police.fine",
    "police.announce",
    "-police.store_weapons",
    "-police.seizable",
    "radio.police",
    "policia.perm"
  },
  ["EMS"] = {
    _config = {
      title = "Emergency",
      gtype = "job",
      salario = 2500,
      lvl = 1,
      whitelist = true,
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "emergency.revive",
    "emergency.shop",
    "emergency.service",
    "ems.perm"
  },
  ["Mecânico"] = {
    _config = {
      title = "Repair",
      gtype = "job",
      salario = 500,
      lvl = 1,
      whitelist = false,
      descricao = "Emprego de Mecânico",
      requerimento = "CNH"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "vehicle.repair",
    "vehicle.replace",
    "repair.service",
    "mecanico.fix"
  },
  ["Uber"] = {
    _config = {
      title = "Uber",
      gtype = "job",
      salario = 2200,
      lvl = 1,
      whitelist = false,
      descricao = "Emprego de Uber",
      requerimento = "CNH e Carro"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "uber.service"
  },
  ["CET"] = {
    _config = {
      title = "CET",
      gtype = "job",
      salario = 1200,
      lvl = 1,
      whitelist = true,
      descricao = "Emprego de CET",
      requerimento = "CNH"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "cet.service"
  },
  ["Pescador"] = {
    _config = {
      title = "Pescador",
      gtype = "job",
      salario = 0,
      lvl = 2,
      whitelist = false,
      descricao = "Pegar uns peixes",
      requerimento = "Barco e vara de pescar"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "pesca.perm"
  },
  ["Lixeiro"] = {
    _config = {
      title = "Lixeiro",
      gtype = "job",
      salario = 900,
      lvl = 3,
      whitelist = false,
      descricao = "Pegar lixo pela cidade",
      requerimento = "Ser Lixeiro"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "lixo.perm"
  },
  ["Lenhador"] = {
    _config = {
      title = "Lenhador",
      gtype = "job",
      salario = 600,
      lvl = 5,
      whitelist = false,
      descricao = "Cortar por ai",
      requerimento = "Machado"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
    "lenhador.perm"
  },
  ["Desempregado"] = {
    _config = {
      title = "Citizen",
      gtype = "job",
      salario = 0,
      lvl = 1,
      whitelist = false,
      descricao = "Ser vagabundo",
      requerimento = "Ser burro"
    },
    _imagens = {
      img1 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img2 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img3 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img4 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg",
      img5 = "https://cdn.ligadosgames.com/imagens/gtaepsilonnorte.jpg"
    },
  }
}

cfg.users = {
  [1] = { 
    "admin"
  }
}

cfg.selectors = {}

return cfg

