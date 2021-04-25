local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local PULA_LINHA = '\r\n'

local DOUBLE_LN = '\r\n\r\n'
local TRIP_LN = '\r\n\r\n\r\n'

local suelLog = {}

vRP._prepare('suel_Log/get_userMoney', "SELECT * FROM vrp_user_moneys WHERE user_id = @user_id")
vRP._prepare("suel_log/get_userIdentifies","SELECT * FROM vrp_user_ids WHERE user_id = @user_id")
vRP._prepare("suel_log/get_vehicles","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP._prepare("suel_log/get_homeuserid","SELECT * FROM vrp_homes_permissions WHERE user_id = @user_id")
vRP._prepare("suel_log/get_allUsers", "SELECT u.id AS id, urg.name AS nome, urg.firstname AS sobrenome, udata.dvalue AS data FROM vrp_users u INNER JOIN vrp_user_identities urg ON urg.user_id = u.id INNER JOIN vrp_user_data udata ON u.id = udata.user_id WHERE whitelisted = true AND banned = FALSE AND udata.dkey LIKE 'vRP:datatable'")

function suelLog.getCars(user_id)
    return vRP.query( "suel_log/get_vehicles", { user_id = user_id } )
end

function suelLog.getHomes(user_id)
    return vRP.query( "suel_log/get_homeuserid", { user_id = user_id } )
end

function suelLog.getUserMoney(user_id)
    return vRP.query( "suel_Log/get_userMoney", { user_id = user_id } )
end

function suelLog.getUserIdentifies(user_id)
    return vRP.query( "suel_log/get_userIdentifies", { user_id = user_id } )
end

function suelLog.IsPlayerOnline( user_id )
    return vRP.getUserSource(user_id) ~= nil
end


function formatarInventario(inventario, embeds)
   
    local items = ""
   
    for item, p in pairs( inventario ) do       
        items = ("%s: %d%s%s"):format(item, p.amount, PULA_LINHA, items)
    end
    
    table.insert(embeds, {
        title = ":handbag: Inventário :handbag:",
        color = tonumber("0x1ca683"),
        description = ("Informações sobre o inventário%s%s"):format(DOUBLE_LN, items)
    })

    return embeds
end

function formatarArmas(a, embeds)
    local items = ""
    local armas = a or {{}}    
    if #armas ~= 1 then
        for item, p in pairs( armas ) do           
            items = ("**%s** - Munição: %d%s%s"):format(vRP.getItemName('wbody|' .. item), p.ammo, PULA_LINHA, items)
        end
    else
        items = "CIDADÃO NÃO POSSUI ARMAS"
    end


    table.insert(embeds, {
        title = ":gun: Armas :gun:",
        color = tonumber("0xff00ae"),
        description = ("Informações sobre armas%s%s"):format(DOUBLE_LN, items)
    })

    return embeds
end

function formatarCarros(embeds, user_id)
    
   local carros = suelLog.getCars(user_id)

   local quantidades = #carros

   local idsCarros = ""
   local bausCarros = ""

   for k, v in pairs( carros ) do
        idsCarros = ("%s, %s"):format(v.vehicle, idsCarros)
        local bauObject = json.decode(vRP.getSData("chest:u" .. v.user_id .. "veh_" .. v.vehicle)) or {{}}
        if #bauObject ~= 1 then
            local items = ""
            for y, x in pairs( bauObject ) do
                 items = ("%s: %d%s%s"):format(y, x.amount, PULA_LINHA, items)
            end
            bausCarros = ("**%s**:%s%s%s%s%s"):format(v.vehicle, PULA_LINHA, items, PULA_LINHA, bausCarros, DOUBLE_LN) 
        else          
           bausCarros = ("**%s**: NENHUM ITEM NO PORTA-MALAS"):format(v.vehicle)           
        end
   end

   local d = ""

   if quantidades > 0 then
        d = ("Informações sobre veículos%s**Quantidade**: %d%s**Veículos**: %s%s**Itens no porta-malas**:%s%s"):format(DOUBLE_LN, quantidades, DOUBLE_LN, idsCarros, DOUBLE_LN, DOUBLE_LN, bausCarros)
   else
        d = "CIDADÃO NÃO POSSUI VEÍCULOS"
   end
   
   table.insert(embeds, {
        title = ":red_car: Carros :red_car:",
        color = tonumber("0xd217e3"),
        description = d
    });

   return embeds

end

function formatarCasa(embeds, user_id)
    local casas = suelLog.getHomes(user_id)
    local quantidade = #casas
    local d = ""
    if quantidade > 0 then
        local idsCasas = ""
        local bausCasas = ""
        
        for k,v in pairs( casas ) do        
            idsCasas = ("%s, %s"):format(v.home, idsCasas)
            local bauCasa = json.decode( vRP.getSData( "chest:" .. v.home )) or {{}}
            local items = ""
            if #bauCasa == 1 then
                --NÃO TEM NADA
                items = ("NENHUM ITEM NO BAÚ%s"):format(items)
            else
                for y, x in pairs( bauCasa ) do
                    items = ("%s: %d%s%s"):format(y, x.amount, PULA_LINHA, items)
                end
            end                     
            bausCasas = ("**%s**:%s%s%s%s"):format(v.home, DOUBLE_LN, items, PULA_LINHA, bausCasas)
            
        end
        d = ("Informações sobre as casas%sQuantidade: %d%sCasas: %s%sBaú das casas:%s%s"):format(DOUBLE_LN, quantidade, DOUBLE_LN, idsCasas, DOUBLE_LN, DOUBLE_LN, bausCasas )
    else
        d = "CIDADÃO NÃO TEM CASAS"
    end

    table.insert(embeds, {
        title = ":house: Casas :house:",
        color = tonumber("0x0c4a09"),
        description = d
    });

    return embeds

end

function formatarDinheiro(embeds, user_id)

    local db, dc = 0, 0
    
    if suelLog.IsPlayerOnline(user_id) then
        db = vRP.getBankMoney(user_id)
        dc = vRP.getMoney(user_id)
    else        
        local row = suelLog.getUserMoney(user_id)
        if row[1] ~= nil then
            db = row[1].bank
            dc = row[1].wallet
        end
    end

    table.insert(embeds, {
        title = ":money_with_wings: Informações de dinheiro :money_with_wings:",
        color = tonumber("0x0c4a09"),
        description = ("**Dinheiro no banco**: $%s%s**Dinheiro na carteira**: $%s"):format(vRP.format(db), PULA_LINHA, vRP.format(dc))
    });

    return embeds
end


function formatarInformacoesPessoais(embeds, datatable, user_id)
    local rg = vRP.getUserIdentity(user_id)
    local vida  = datatable.health
    local colete = datatable.colete
    local nome = rg.name .. " " .. rg.firstname
    local id = user_id
    local isOnline = _bool_to_human_readable( suelLog.IsPlayerOnline( user_id ) )
    local banido = _bool_to_human_readable( vRP.isBanned(user_id) )
    local allowed = _bool_to_human_readable( vRP.isWhitelisted(user_id))
    local ultima_posicao = json.encode( datatable.position )
    local registro = rg.registration
    local telefone = rg.phone
    local grupos = json.encode(datatable.groups)

    table.insert(embeds, 
        {
            title = ":information_source: Informações Pessoais :information_source:",
            color = tonumber("0xff1100"),
            description = 
            ("**ID**: %s%s**Nome**: %s%s**Registro**: %s%s**Telefone**: %s%s**Vida**: %s%s**Colete**: %s"):format(
                 id, PULA_LINHA,
                 nome, PULA_LINHA,
                 registro,PULA_LINHA,
                 telefone,PULA_LINHA,
                 vida,PULA_LINHA,
                 colete
              )
        })

    table.insert(embeds,  {
            title = ":information_source: Outras Informações :information_source:",
            color = tonumber("0xff1122"),
            description = ("**Tá Online**: %s%s**Tá Banido**: %s%s**Vez Allowlist**: %s%s**Grupos**: %s%s**Última posição**: %s"):format(
                isOnline,PULA_LINHA,
                banido,PULA_LINHA,
                allowed,PULA_LINHA,
                grupos,PULA_LINHA,
                ultima_posicao
            )
    })

    return embeds

end

function formatarLicencas(embeds, user_id)


    local rows = suelLog.getUserIdentifies(user_id)
    local d = "NENHUM LICENÇA ENCONTRADA"
    
    if #rows > 0 then
       d = ""
       for k, v in pairs( rows ) do
        d = ("%s%s%s"):format(v.identifier, PULA_LINHA, d)
       end
    end


    table.insert(embeds, {
        title = ":memo: Licenças :memo:",
        color = tonumber("0x05f0d8"),
        description = d
    })

    return embeds
end

function _bool_to_human_readable(bool)
    if bool then
        return "Sim"
    else 
        return "Não"
    end
end


function sendToOut(s, m)
    if s == 0 then
        print(m)
    else 
        sendChatNotify(m, s)
    end 
end

function sendToDiscordOrPrint( p, emb, w )
    if p == "c" then
        print(json.encode(emb))
    else       
        PerformHttpRequest(w, function(err,text, headers)end, 'POST', json.encode(emb), { ['Content-Type'] = 'application/json' })
    end
end

function criarParams(args, s, webhook )
    print(json.encode(args))
    if args and args[1] and args[2] and args[3] then
        local saida = args[1]
        local tipo = args[2]
        local id_nome = args[3]

        if saida == "d" or saida == "c" then
            if tipo == "p" or tipo == "f" then
                if id_nome ~= nil then
                    local eb = {}
                    if tipo == "p" then
                        eb = MontarEmbed(parseInt(id_nome))
                    else
                        eb = MontarEmbedFacs(id_nome)
                    end
                    sendToDiscordOrPrint( saida, eb, webhook )
                else
                    local m = "Terceiro parâmetro não encontrado"
                    sendToOut(s, m)
                end
            else
                local m = "Segundo parâmetro incorreto: Precisa ser ^1p^0 para jogadores ou ^1f^0 para facções"
                sendToOut(s, m)
            end
        else 
            local m = "Primeiro parâmetro incorreto: Precisa ser ^1d^0 enviar para o discord ou ^1c^0 para mostrar no terminal." 
            sendToOut(s, m)
        end
    else
        local m = "Verifique os parâmetros: /auditar [d|c] [p|f] [id|grupo]"
        sendToOut(s, m)
    end
end
--[[
    auditar [d|c] [p|f] [id|grupo]
]]
RegisterCommand('auditar', function(s,a,r)
    local wh_link = GetResourceMetadata(GetCurrentResourceName(), "discord_webhook", 0)    
    if s == 0 then
        criarParams(a, s, wh_link)
    else
        if IsPlayerAceAllowed(s,  "command.auditar") then
            criarParams(a, s, wh_link)
        else
            sendChatNotify("AÇÃO NÃO PERMITIDA", s) 
        end
    end
end)

function MontarEmbed(user_id)
    local vrp_datatable = json.decode( vRP.getUData(user_id,'vRP:datatable') )
    local eb = {};
    eb = formatarInformacoesPessoais(eb, vrp_datatable, user_id)
    eb = formatarLicencas(eb, user_id)  
    eb = formatarDinheiro(eb, user_id)
    eb = formatarArmas(vrp_datatable.weapons, eb)
    eb = formatarInventario(vrp_datatable.inventory, eb) 
    eb = formatarCarros(eb, user_id)   
    eb = formatarCasa(eb, user_id)
    return {embeds = eb}
end


function prepararListaDePlayerNaFac( embed, facGroup )
    local usuarios = {}
    local tu = vRP.query( 'suel_log/get_allUsers' )
    
    for k, v in pairs( tu ) do
        local data = json.decode(v.data)
        if data.groups[facGroup] then      
            usuarios[k] = { id = v.id, nome = v.nome .. " " .. v.sobrenome }
        end
    end

    local d = "Quantidade de membros: " .. #usuarios .. DOUBLE_LN

    if #usuarios > 0 then
        d = "**LISTA DE MEMBROS**" .. DOUBLE_LN
        for _, user in pairs( usuarios ) do
            d = ("%s**%d** - %s%s"):format( d, user.id, user.nome, PULA_LINHA )
        end
    end

    d = d .. DOUBLE_LN .. "**INFORMAÇÕES DO BAÚ**" .. DOUBLE_LN

    local data_bau = json.decode(vRP.getSData("chest:"..facGroup)) or {{}}
    if #data_bau == 1 then
        d = d .. "BAÚ VÁZIO"
    else
        local items = ""
        
        for k, v in pairs( data_bau ) do
            items = ("%s: %d%s%s"):format(k, v.amount, PULA_LINHA, items)
        end

        d = d .. items
    end

    table.insert(embed, {
        title = ':goggles: Informações da '..facGroup..' :goggles:',
        color = tonumber("0xccdd00"),
        description = d
    })

    return embed
end   

function MontarEmbedFacs(facGroup)
    local eb = {}
    eb = prepararListaDePlayerNaFac(eb, facGroup)
    return {embeds = eb }
end


function sendChatNotify( message, s )
    TriggerClientEvent('chat:addMessage', s, {
        color = { 255, 0, 0},
        multiline = false,
        args = {"Sistema ", message}
    }) 
end