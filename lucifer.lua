local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRP._prepare("suel_log/get_userIdentifies","SELECT * FROM vrp_user_ids WHERE user_id = @user_id")
vRP._prepare("suel_log/get_vehicles","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP._prepare("suel_log/get_homeuserid","SELECT * FROM vrp_homes_permissions WHERE user_id = @user_id")

local suelLog = {}


RegisterCommand('playerinfo', function(source, args, rawCommand)
    local user_id = parseInt(args[1])
    if user_id and user_id > 0 then
        local onlyPrint = parseInt(args[2])
        if source ~= 0 then
            if IsPlayerAceAllowed(source, "command.playerinfo") then
                prepararInformacoes(user_id, onlyPrint)  
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = { 255, 0, 0},
                    multiline = false,
                    args = {"Sistema", "Comando não permitido para ser usado por você!"}
                })
            end
        else
            prepararInformacoes(user_id, onlyPrint)             
        end
    else
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0},
                multiline = false,
                args = {"Sistema", "ID não encontrado."}
            }) 
        else
            print('^0Especifique o ^1ID^0 do ^3usuário^0 do qual você deseja ^8informações.^0')
        end
    end
end, true)



function suelLog.getUserIdentifies(user_id)
    return vRP.query( "suel_log/get_userIdentifies", { user_id = user_id } )
end

function suelLog.getHomes(user_id)
    return vRP.query( "suel_log/get_homeuserid", { user_id = user_id } )
end

function suelLog.getCars(user_id)
    return vRP.query( "suel_log/get_vehicles", { user_id = user_id } )
end

function suelLog.prepareCars(cars)
    local carros = {}
    for k, v in pairs( cars ) do
        carros[v.vehicle] = json.decode(vRP.getSData("chest:u" .. v.user_id .. "veh_" .. v.vehicle)) or {}
    end
    return carros
end

function suelLog.prepareCasas(_casas)    
    local casas = {}
    for k, v in pairs(_casas) do
        casas[v.home] = json.decode( vRP.getSData( "chest:" .. v.home )) or {}
    end
    return casas
end

function suelLog.prepareLicense(_licencas)
    local  l = {}
    for k, v in pairs(_licencas) do
        l[k] = v.identifier
    end
    return l
end

function prepararInformacoes(user_id, onlyPrint)
    local vrp_datatable = json.decode( vRP.getUData(user_id,'vRP:datatable') )
    local identity = vRP.getUserIdentity(user_id)

    local dinheiro_banco = vRP.getBankMoney(user_id)
    local dinheiro_mao = vRP.getMoney(user_id)

    local id = user_id
    local nome = identity.firstname .. " " .. identity.name
    local registro = identity.registration
    local telefone = identity.phone

    local whitelisted = vRP.isWhitelisted(user_id)
    local ta_banido = vRP.isBanned(user_id)
    local vida_atual = vrp_datatable.health
    local colete_atual = vrp_datatable.colete

    local armas = vrp_datatable.weapons
    local grupos = vrp_datatable.groups
    local inventario = vrp_datatable.inventory
    local ultima_posicao = vrp_datatable.position
    local licencas = suelLog.prepareLicense(suelLog.getUserIdentifies(user_id))

    local casas = suelLog.prepareCasas(suelLog.getHomes(user_id))
    local carros = suelLog.prepareCars(suelLog.getCars(user_id))

    if (onlyPrint ~= 0) then
        print("")
        print('ID: ', id)
        print('Nome: ', nome)
        print('Registro:', registro)
        print('Telefone:', telefone)
        print("")
        print('Vida:', vida_atual)
        print('Colete:', colete_atual)
        print("")
        print('Dinheiro no Banco: ', vRP.format(dinheiro_banco))
        print('Dinheiro na carteira: ', vRP.format(dinheiro_mao))
        print("")
        print('Allowed:', whitelisted)
        print("Banido: ", ta_banido)
        print("")
        print("Armas: ", json.encode(armas))
        print("Inventário: ", json.encode(inventario))
        print("Ultima Posição: ", json.encode(ultima_posicao))
        print("")
        print("Licenças:\n", json.encode(licencas))
        print("")
        print('Casas:', json.encode(casas))
        print("")
        print('Carros:', json.encode(carros))
        print("")        
    else
        enviarWebhook(id, nome, registro, telefone, vida_atual, colete_atual, vRP.format(dinheiro_banco), vRP.format(dinheiro_mao), whitelisted, ta_banido, json.encode(armas), json.encode(inventario), json.encode(ultima_posicao), json.encode(licencas), json.encode(casas), json.encode(carros))
    end
end


function _bool_to_human_readable(bool)
    if bool then
        return "Sim"
    else 
        return "Não"
    end
end

function enviarWebhook(
    id, nome, registro, telefone, vida_atual, colete_atual, 
    dinheiro_banco, dinheiro_mao, whitelisted, ta_banido, 
    armas, inventario, ultima_posicao, licencas, casas, carros)
    local webhook = {}
    webhook['embeds'] = {
        {
            title = ":information_source: Informações Pessoais :information_source:",
            color = tonumber("0xff1100"),
            description = ("```Id: %d\nNome: %s\nRegistro: %s\nTelefone: %s\nPassou na AllowList: %s\nTá banido: %s\nÚltima posição: %s```"):format(id, nome, registro, telefone, _bool_to_human_readable(whitelisted), _bool_to_human_readable(ta_banido), ultima_posicao)
        },
        {
            title = ":money_with_wings: Informações de dinheiro :money_with_wings:",
            color = tonumber("0x3cff00"),
            description = ("```Dinheiro no banco: $%s\nDinheiro na carteira: $%s```"):format(dinheiro_banco, dinheiro_mao)
        },
        {
            title = ":heart: Informações de Saúde :heart:",
            color = tonumber("0xdbdb09"),
            description = ("```Vida: %d\nColete: %d```"):format(vida_atual, colete_atual)
        },
        {
            title = ":gun: Armas :gun:",
            color = tonumber("0xff00ae"),
            description = ("```%s```"):format(armas)
        },
        {
            title = ":handbag: Inventário :handbag:",
            color = tonumber("0x1ca683"),
            description = ("```%s```"):format(inventario)
        },
        {
            title = ":red_car: Carros :red_car:",
            color = tonumber("0xd217e3"),
            description = ("```%s```"):format(carros)
        },
        {
            title = ":house: Casas :house:",
            color = tonumber("0x0c4a09"),
            description = ("```%s```"):format(casas)
        },
        {
            title = ":memo: Licenças :memo:",
            color = tonumber("0x05f0d8"),
            description = '```'.. licencas ..'```'
        },

    }
    local wh_link = GetResourceMetadata(GetCurrentResourceName(), "discord_webhook", 0)
    if wh_link ~= nil then
        PerformHttpRequest(wh_link, function(err,text, headers)end, 'POST', json.encode(webhook), { ['Content-Type'] = 'application/json' })
    else
        print('WEBHOOK NÃO ESPECIFICADO NO FXMANIFEST discord_webhook')
    end
end

