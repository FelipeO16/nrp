vRP.prepare("vRP/vehicles_table", [[
  CREATE TABLE IF NOT EXISTS vrp_user_vehicles(
    user_id INTEGER,
    vehicle VARCHAR(100),
    state BOOLEAN,
    placa VARCHAR(100),
    tipo text(255),
    img text(255),
    motor VARCHAR(100),
    lataria VARCHAR(100),
    gasolina VARCHAR(100),
    custom TEXT,
    bau TEXT,
    bauLimite INTEGER,
    CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
    CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
  );
]])

vRP.prepare("vRP/add_vehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,state,placa,img,tipo,motor,lataria,gasolina,bau,bauLimite,custom,ipva) VALUES(@user_id,@vehicle,@state,@placa,@img,@tipo,@motor,@lataria,@gasolina,@bau,@bauLimite,@custom, @ipva)")
vRP.prepare("vRP/remove_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vRP/get_vehicles","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP.prepare("vRP/get_vehicle_by_model","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id and vehicle = @vehicle")

vRP.prepare("NL/get_bauCar","SELECT bau, bauLimite from vrp_user_vehicles WHERE placa = @placa")
vRP.prepare("NL/set_bauCars","UPDATE vrp_user_vehicles SET bau = @bau WHERE placa = @placa")

vRP.prepare("vRP/get_veh_by_plate","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND placa = @placa")
vRP.prepare("vRP/selecionar_veh_placa","SELECT * FROM vrp_user_vehicles WHERE placa = @placa")

vRP.prepare("vRP/get_vehicles_by_states","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND state = @state")
vRP.prepare("vRP/get_vehicle","SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vRP/upp_state","UPDATE vrp_user_vehicles SET state = @state WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vRP/set_vehstatus","UPDATE vrp_user_vehicles SET motor = @motor, lataria = @lataria, gasolina = @gasolina WHERE user_id = @user_id AND vehicle = @vehicle")


-- init
async(function()
  vRP.execute("vRP/vehicles_table")
end)
