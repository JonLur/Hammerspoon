-------------------------
-- Hammerspoon config
-- File: dagliglogg.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.12.23
-- Version: 3.0.0
------------------------

kommandoer = "STOPP EXPORT DAG UKE MND"
-- Ok kommandoer er
-- STOPP
-- EXPORT [DAG/UKE/MND/num]
-- num er da enten dato i format YYYYMMDD eller uke i format YYYYWW 

-- Database format:
-- timestamp - YYYYMMDDHHMMSS
-- lengde - integer hentet fra starten av tekst som er lagt inn eller via en STOPP kommando
-- text - Beskrivelse

db_dagliglogg = nil
db_dagliglogg_directory = "/Users/jon/Documents/DagligLogg/"
db_dagliglogg_file = "dagliglogg.sqlite3"
db_dagliglogg_table = "daglig"

-- sqlite3.open - open if exists - creates if not
-- create table if not exists TableName (col1 typ1, ..., colN typN)
-- db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)
-- currdir = hs.fs.currentDir()
-- result = hs.fs.chdir(db_dagliglogg_dir)
db_dagliglogg = hs.sqlite3.open(db_dagliglogg_directory .. db_dagliglogg_file)
db_dagliglogg:exec("CREATE TABLE IF NOT EXISTS " .. db_dagliglogg_table .. " (timestamp STRING, lengde INTEGER, text STRING)")
db_dagliglogg:close()

function get_last_time(db)
    local stmt = db:prepare("SELECT max(timestamp) FROM daglig")

    if not stmt then
        -- Handle the error (e.g., print an error message, log, or throw an exception)
        print("Error preparing SQL statement")
        return nil, "Error preparing SQL statement"
    end

    local success = stmt:step()

    if not success then
        -- Handle the error (e.g., print an error message, log, or throw an exception)
        print("Error executing SQL statement")
        stmt:finalize()  -- Ensure to finalize the statement in case of an error
        return nil, "Error executing SQL statement"
    end

    local lasttime = stmt:get_value(0)

    if not lasttime then
        -- Handle the error (e.g., print an error message, log, or throw an exception)
        print("Error retrieving value from the result set")
        stmt:finalize()  -- Ensure to finalize the statement in case of an error
        return nil, "Error retrieving value from the result set"
    end

    stmt:finalize()  -- Finalize the statement after successful execution

    return lasttime
end

function get_last_lengde_text(db)
    return function (lasttime)
        local stmt = db:prepare("SELECT lengde, text FROM daglig WHERE timestamp = " .. lasttime )

        if not stmt then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error preparing SQL statement")
            return nil, "Error preparing SQL statement"
        end

        local success = stmt:step()

        if not success then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error executing SQL statement")
            stmt:finalize()  -- Ensure to finalize the statement in case of an error
            return nil, "Error executing SQL statement"
        end


        local lastlengde = stmt:get_value(0)
        if not lastlengde then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error retrieving value from the result set")
            stmt:finalize()  -- Ensure to finalize the statement in case of an error
            return nil, "Error retrieving value from the result set"
        end

        local lasttext = stmt:get_value(1)

        if not lasttext then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error retrieving value from the result set")
            stmt:finalize()  -- Ensure to finalize the statement in case of an error
            return nil, "Error retrieving value from the result set"
        end

        stmt:finalize()  -- Finalize the statement after successful execution

        return lastlengde, lasttext
    end
end

function get_report(db)
    return function(periodestart, periodeslutt, periodesummering, rapportfilnavn)
        local outputfile = db_dagliglogg_directory .. rapportfilnavn
        local totalsum = 0

        if (hs.fs.displayName(outputfile) ~= nil) then
            os.remove(outputfile)
        end

        local stmt = db:prepare("SELECT * FROM daglig WHERE (timestamp > ?) and (timestamp < ?)")
        if not stmt then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error preparing SQL statement")
            return false, "Error preparing SQL statement"
        end
        stmt:bind(1,periodestart)
        stmt:bind(2,periodeslutt)
        -- Open the output file in append mode
        local file, file_error = io.open(outputfile, "a")
        if not file then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error opening output file:", file_error)
            stmt:finalize()  -- Ensure to finalize the statement in case of an error
            return false, "Error opening output file: " .. file_error
        end

        -- Write headers
        local header_line = string.format("%s\t\t%s\t%s\n", "Tidspunkt", "Lengde", "Tekst")
        local write_success, write_error = file:write(header_line)
        if not write_success then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error writing headers to the file:", write_error)
            file:close()  -- Ensure to close the file in case of an error
            stmt:finalize()  -- Ensure to finalize the statement in case of an error
            return false, "Error writing headers to the file: " .. write_error
        end

        -- Loop through the results and print them to the file
        while stmt:step() == hs.sqlite3.ROW do
            local timestamp = os.date("%Y.%m.%d %H:%M",os.time(time_from_string(stmt:get_value(0)))) -- timestamp
            local lengde = stmt:get_value(1)  -- lengde
            local tekst = stmt:get_value(2)  -- tekst

            -- Check for errors when retrieving values
            if not timestamp or not lengde or not tekst then
                -- Handle the error (e.g., print an error message, log, or throw an exception)
                print("Error retrieving values from the result set")
                file:close()  -- Ensure to close the file in case of an error
                stmt:finalize()  -- Ensure to finalize the statement in case of an error
                return false, "Error retrieving values from the result set"
            end

            if (periodesummering) then
                totalsum = totalsum + lengde
            end

            -- Print or format the values as needed
            local line = string.format("%s\t%5sm\t%s\n", timestamp, lengde, tekst)
            write_success, write_error = file:write(line)
            if not write_success then
                -- Handle the error (e.g., print an error message, log, or throw an exception)
                print("Error writing line to the file:", write_error)
                file:close()  -- Ensure to close the file in case of an error
                stmt:finalize()  -- Ensure to finalize the statement in case of an error
                return false, "Error writing line to the file: " .. write_error
            end
        end

        if (periodesummering) then
            -- Print or format the values as needed
            local min = totalsum % 60
            local timer = (totalsum-min) / 60
            sum = string.format("%d:%d", timer, min)
            local line = string.format("%s\t\t\t%5st\t%s\n", "Totalt", sum, "")
            write_success, write_error = file:write(line)
            if not write_success then
                -- Handle the error (e.g., print an error message, log, or throw an exception)
                print("Error writing line to the file:", write_error)
                file:close()  -- Ensure to close the file in case of an error
                stmt:finalize()  -- Ensure to finalize the statement in case of an error
                return false, "Error writing line to the file: " .. write_error
            end
        end

        -- Finalize the statement
        stmt:finalize()

        -- Close the file
        file:close()

        return true
    end
end

function oppgave(db)
    return function(oppgave_text)
        local result
        local current_time = time_formated(os.time())
        local used_time = 0
        local first_word_index = string.find(oppgave_text, " ")
        local first_word = string.sub(oppgave_text,1,first_word_index-1)

        -- Start with number
        local is_number = tonumber(string.sub(first_word,1,1))
        if (is_number ~= nil) then
            used_time = get_time(first_word)
            text = string.sub(oppgave_text, first_word_index+1)
        else
            -- Ingen tid angitt
            used_time = 0
            text = oppgave_text
        end;

        db:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES ('" .. current_time .. "', " .. used_time .. ", '" .. text .. "')")
        return db:error_code()
    end
end

function dagliglogg_ny(db_daglig)
    local respons, beskrivelse, spaceindex, timeformat, lengde
    local kontroll = false
    local rapportsummering = false
    local ukenr = nil
    local dato = nil

    local last_time, errormessage = get_last_time(db_daglig)
    if not last_time then
        print("Error:", errormessage)
        return 
    end

    f_lengde_tekst = get_last_lengde_text(db_daglig)
    lastlengde, lasttext = f_lengde_tekst(last_time)
    if not lastlengde then
        print("Error:", errormessage)
        return 
    end
    if not lasttext then
        print("Error:", errormessage)
        return 
    end

    local stamp = os.date("%H:%M",os.time(time_from_string(last_time)))

    hs.focus()
    if (lastlengde == 0) then
        statustext = "Siste er " .. stamp .. ": " .. lasttext
    else
        statustext = "Hva skjer?"
    end
    respons, beskrivelse = hs.dialog.textPrompt("Daglig logg", statustext, "Start gjerne med minutter.", "OK", "Cancel")

    local f_time_diff = time_diff_in_minutes(time_formated(os.time()))
    local used_time = f_time_diff(last_time)

    if (respons == "OK") then
        TekstInput = UpperAllText(splitCommandFromSentence(beskrivelse))

        if (string.find(kommandoer, TekstInput[1]) ~= nil ) then
            if (TekstInput[1] == 'STOPP') then
                if (lastlengde == 0) then
                    db_daglig:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. used_time .. " WHERE timestamp = '" .. last_time .. "' ")
                end
            elseif (TekstInput[1] == 'EXPORT') then
                if (TekstInput[2] == nil) then 
                    -- EXPORT DAG gir rapport for gjeldende dag
                    now = os.time()
                    aRapport = rapport_innstillinger_dag(now)
                elseif (string.find(kommandoer, TekstInput[2]) ~= nil ) then
                    if (TekstInput[2] == 'DAG') then
                        -- EXPORT DAG gir rapport for gjeldende dag
                        now = os.time()
                        aRapport = rapport_innstillinger_dag(now)
                    elseif (TekstInput[2] == 'UKE') then
                        -- EXPORT UKE gir rapport for gjeldende uke
                        now = os.time()
                        aRapport = rapport_innstillinger_uke(now)
                    elseif (TekstInput[2] == 'MND') then
                        -- EXPORT MND gir rapport for gjeldende måned
                        now = os.time()
                        aRapport = rapport_innstillinger_mnd(now)
                    end
                elseif (tonumber(TekstInput[2]) ~= nil) then
                    -- Ukenummer i format YYYYWW
                    local n = string.len(TekstInput[2])
                    if (n == 6) then
                        local ukenr = TekstInput[2]
                        local f_year_seconds = MondayInWeekInSeconds(string.sub(ukenr,1,4))
                        local monday_seconds = f_year_seconds(string.sub(ukenr,5,6))
                        aRapport = rapport_innstillinger_uke(monday_seconds)
                    elseif (n == 8) then
                        -- Dato i format YYYYMMDD
                        local dag_seconds = os.time(time_from_string(TekstInput[2]))
                        aRapport = rapport_innstillinger_dag(dag_seconds)
                    end
                else
                    error_message = "Ukjent parameter etter EXPORT kommando."
                    print("Error:", error_message)
                    return
                end

                local f_report = get_report(db_daglig)
                local success, error_message = f_report(aRapport["start"], aRapport["stopp"], aRapport["summering"], aRapport["filnavn"])
                if not success then
                    print("Error:", error_message)
                end  
            end
        else
            f_oppgave = oppgave(db_daglig)
            local success = f_oppgave(beskrivelse)
            if success ~= 0 then
                print("Error:", error_message)
            end
        end
    end
end