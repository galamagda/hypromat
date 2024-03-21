local json = require("hypromat/json")

function command_list()
    border()
    print("\27[94m" .. "    Commands" .. "\27[0m" .. "\n")
    print("\27[94m" .. "    1 - Dump" .. "\27[0m")
    print("\27[94m" .. "    2 - Solde" .. "\27[0m")
    print("\27[94m" .. "    3 - Search lf" .. "\27[0m")
    print("\27[94m" .. "    4 - Code site" .. "\27[0m")
    print("\27[94m" .. "    5 - Scan" .. "\27[0m")
    print("\27[94m" .. "    6 - Info" .. "\27[0m")
    print("\27[94m" .. "\n    0 - Return\n\n" .. "\27[0m")
    io.write("\27[94m" .. "Choix : " .. "\27[0m")
    action = io.read()
    if action == "1" then
        dump()
    elseif action == "2" then
        credit()
    elseif action == "3" then
        search()
    elseif action == "4" then
        code_site()
    elseif action == "5" then
        scan()
    elseif action == "6" then
        info()
    elseif action == "0" then
        home()
    else
        print("\27[31m" .. '"' .. action .. '" n\'est pas une commande valide' .. "\27[0m")
        return command_list()
    end
end

function setting_list()
    border()
    print("\27[94m" .. "    Settings\n" .. "\27[0m")
    print("\27[94m" .. "    1 - Taer off" .. "\27[0m")
    print("\27[94m" .. "    2 - Reset 125khz" .. "\27[0m")
    print("\27[94m" .. "\n    0 - Return\n\n" .. "\27[0m")
    io.write("\27[94m" .. "Choix : " .. "\27[0m")
    action = io.read()
    if action == "1" then
        -- taer_off()
        print("\27[93m" .. "Tear off bientot disponible" .. "\27[0m")
        return setting_list()
    elseif action == "2" then
        core.console("lf config --125")
        wait(1)
        return setting_list()
    elseif action == "0" then
        return home()
    else
        print("\27[31m" .. '"' .. action .. '" n\'est pas une commande valide' .. "\27[0m")
        return setting_list()
    end
end

function tear_off()
    core.console("lf config --taer_off")
    return setting_list()
end

function wait(time)
    local duration = os.time() + time
    while os.time() < duration do
    end
end

function credit_lsb(val)
    local hex = "00000000" .. val
    return string.sub(hex, -8)
end

function credit()
    local rep = boucle()
    io.write("\27[94m" .. "Nouveau solde : " .. "\27[0m")
    local s = tonumber(io.read())
    local s_slb = credit_lsb(string.format("%x", s * 10))
    write_credit_lsb(s, s_slb, rep)
    return command_list()
end

function write_credit_lsb(a, s, rep)
    print("\27[92m" .. "ecriture de " .. a .. " euros sur bloc 5 et 9" .. "\27[0m")
    print("\27[93m" .. "bloc=" .. s .. "\27[0m")
    for _ = 1, rep do
        boucle_print(_, rep)
        core.console(string.format('lf em 4x50 wrbl -b 5 -d ' .. s))
        core.console(string.format('lf em 4x50 wrbl -b 9 -d ' .. s))
    end
end

function info()
    local rep = boucle()
    print("\27[92m" .. "Informations" .. "\27[0m")
    for _ = 1, rep do
        boucle_print(_, rep)
        core.console("lf em 4x50 info")
    end
    return command_list()
end

function search()
    local rep = boucle()
    print("\27[92m" .. "recherche de badge LF" .. "\27[0m")
    for _ = 1, rep do
        boucle_print(_, rep)
        core.console("lf search")
    end
    return command_list()
end


function fetch_code_site()
    os.execute("python " .. "hypromat/featpy.py fetch_code_site")
    local file = io.open("hypromat/dataset.json", "r")
    if file then
        local data_str = file:read("*all")
        file:close()
        local parsedData  = json.parse(data_str)

        return parsedData
    else
        return nil
    end
end


function code_site()
    border()
    print("\27[94m" .. "    Modifier le code site" .. "\27[0m" .. "\n")
    print("")
    local data = fetch_code_site()
    for i = 1, #data do
        local obj = data[i]
        local city = obj["properties"].city or "inconnu"
        local postcode = obj["properties"].postcode or "inconnu"
        local code_site = obj["properties"].code_site or "inconnu"
        if city == "inconnu" and postcode == "inconnu" and code_site == "inconnu" then
            print("\27[91m" .. "  " .. i .. " - " .. city .. " - " .. postcode .. " - " .. code_site .. " ----> Aucune information" .. "\27[0m")
        elseif city == "inconnu" or postcode == "inconnu" or code_site == "inconnu" then
            print("\27[93m" .. "  " .. i .. " - " .. city .. " - " .. postcode .. " - " .. code_site .. " ----> Incomplet" .. "\27[0m")
        else
            print("\27[94m" .. "  " .. i .. " - " .. city .. " - " .. postcode .. " - " .. code_site .. "\27[0m")
        end
    end
    print("\27[94m" .. "\n  0 - Return\n" .. "\27[0m" .. "\n")
    io.write("\27[94m" .. "Choix : " .. "\27[0m")
    local a = tonumber(io.read())
    if a == 0 then
        return command_list()
    end
    local choiced = data[a].properties
    print("\27[92m" .. "Vous avez choisi : " .. a .. " - " .. choiced.city .. " - " .. choiced.postcode .. " - " .. choiced.code_site .. "\27[0m")
    local rep = boucle()
    write_code_site(choiced.code_site, rep)
    return command_list()
end


function write_code_site(a, rep)
    local value = 0
    local n = tonumber(a, 16)
    for _ = 1, 32 do
        value = bit.lshift(value, 1)
        if n ~= 0 then
            value = bit.bor(value, bit.band(n, 1))
            n = bit.rshift(n, 1)
        end
    end
    if value then
        value = string.format("%08x", value)

        print("\27[92m" .. "msb : " .. a .. "\27[0m")
        print("\27[92m" .. "lsb : " .. value .. "\27[0m")
        for _ = 1, rep do
            boucle_print(_, rep)
            core.console("lf em 4x50 wrbl -b 4 -d " .. value)
            core.console("lf em 4x50 wrbl -b 8 -d " .. value)
            core.console("lf em 4x50 wrbl -b 11 -d " .. value)
            core.console("lf em 4x50 wrbl -b 14 -d " .. value)
        end
    else
        print("\27[91m" .. "Invalid hexadecimal number: " .. a .. "\27[0m")
    end
end

function scan()
    print("\27[92m" .. "scanne en cours" .. "\27[0m")
    for i = 100, 151 do
        core.console("lf config -f " .. i)
        core.console("lf search")
    end
    print("\27[92m" .. "parametre remis a 125Khz" .. "\27[0m")
    core.console("lf config --125")
    return command_list()
end

function dump()
    local rep = boucle()
    print("\27[92m" .. "lecture du dump en cours" .. "\27[0m")
    for _ = 1, rep do
        boucle_print(_, rep)
        core.console("lf em 4x50 dump")
    end
    return command_list()
end

function boucle_print(_, rep)
    return print("\27[93m" .. "[".. _ .. "/" .. rep .. "]" .. "\27[0m")
end

function boucle()
    io.write("\27[94m" .. "Nombre de boucle : " .. "\27[0m")
    return tonumber(io.read())
end

function border()
    print("\n" .. "\27[94m" .. "***************************************" .. "\27[0m" .. "\n")
end


function check_for_update()
    local data = nil
    os.execute("python " .. "hypromat/featpy.py fetch_release_info")
    local file = io.open("hypromat/version.txt", "r")
    if file then
        data = file:read("*all")
        file:close()
    end

    if data ~= version then
        print("\27[93m" .. "Une nouvelle version est disponible" .. "\27[0m")
    else
        print("\27[92m" .. "Vous utilisez la derniere version" .. "\27[0m")
    end
end

function home()
    border()
    print("\27[94m" .. "    Home" .. "\27[0m" .. "\n")
    print("\27[94m" .. "    1 - Commands" .. "\27[0m")
    print("\27[94m" .. "    2 - Settings" .. "\27[0m")
    print("\27[94m" .. "\n    0 - Quit\n\n" .. "\27[0m")
    io.write("\27[94m" .. "Choix : " .. "\27[0m")
    action = io.read()
    if action == "1" then
        command_list()
    elseif action == "2" then
        setting_list()
    elseif action == "0" then
        print("\27[92m" .. "Bye" .. "\27[0m")
    else
        print("")
        print("\27[31m" .. '"' .. action .. '" n\'est pas une commande valide' .. "\27[0m")
        home()
    end
end

function main()
    print("\n")
    print("\27[93m" .. hypromat1 .. "\27[0m")
    print("\27[91m" .. hypromat2 .. "\27[0m")
    print("\27[31m" .. hypromat3 .. "\27[0m")
    print("\27[90m" .. "Author : " .. author)
    print("Version : " .. version)
    check_for_update()
    print(desc .. "\27[0m")
    home()
end

copyright = ""
author = "CELL CORE"
version = "1.0.0"
desc = "Ce script facilite la lecture et l'ecriture des tags EM4x50."
hypromat1 = [[    )                                                 )  
 ( /(   (              (              )        )   ( /(  ]]
hypromat2 = (
    [[ )\()) ]] ..
    "\27[93m" ..
    [[ )\ )   `  )    )(     (      (      ( /( ]] ..
    "\27[0m" ..
    "\27[91m" ..
    [[  )\()) 
((_)\  (()/(   /(/(   (()\    )\     )\  '  )(_)) (_))/  ]])
hypromat3 = (
    [[| |]] ..
    "\27[91m" ..
    [[(_)  )(_)) ((_)_\   ((_)  ((_)  _((_))  ((_)_ ]] ..
    "\27[0m" ..
    "\27[31m" ..
    [[ | |_   
| ' \  | || | | '_ \) | '_| / _ \ | '  \() / _` | |  _|  
|_||_|  \_, | | .__/  |_|   \___/ |_|_|_|  \__,_|  \__|  
        |__/  |_|                  
]]
)



main()
