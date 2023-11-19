-------------------------
-- Hammerspoon config
-- File: dagliglogg.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.11.19
-- Version: 2.0.8
------------------------

kommandoer = "EXPORT STOPP"

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

function get_last_lengde_text(db, lasttime)
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


function get_report(db, periodestart, periodeslutt, periodesummering, rapportfilnavn)
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


function get_time_info(word)
-- If last char is number or different from m/t then timeindex = 1
    local length_word = string.len(word)
    local timeformat = string.sub(word,length_word,length_word)
    local timeindex = 1
    local time = 0
    if (tonumber(timeformat) == nil) then
        if (timeformat == 'm') then
            timeindex = 1
            time = tonumber(string.sub(word,1,length_word-1))
        elseif (timeformat == 't') then
            timeindex = 60
            time = tonumber(string.sub(word,1,length_word-1))
        else
-- timeformat is unknown character - then we set time to 0
            timeindex = 1
            time = 0
        end
    else
-- timeformat is a number
        time = tonumber(word)
    end
    return time, timeindex
end

function oppgave(db, current_time, oppgave_text)
    local used_time = 0
    local first_word_index = string.find(oppgave_text, " ")
    local first_word = string.sub(oppgave_text,1,first_word_index-1)

    -- Start with number
    local is_number = string.sub(first_word,1,1)
    if (tonumber(is_number) ~= nil) then

        local time, time_index = get_time_info(first_word)
        used_time = time * time_index
        text = string.sub(oppgave_text, first_word_index+1)
    else
        -- Ingen tid angitt
        used_time = 0
        text = oppgave_text
    end;

    db:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES ('" .. current_time .. "', " .. used_time .. ", '" .. text .. "')")
end

function dato_start(periode)
    local startpunkt = nil

    if (periode == 'DAG') then
        startpunkt = os.date("%Y%m%d000000")
    elseif (periode == 'UKE') then
-- Function to calculate the first day of the week
        local now = os.time()
        local currentDayOfWeek = tonumber(os.date("%w", now))
        if not currentDayOfWeek then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error calculating current day of the week")
            return nil
        end
-- Calculate seconds until the first day of the week (Monday)
        local secondsUntilFirstDay = (currentDayOfWeek - 1) * 24 * 60 * 60
-- Calculate the timestamp for the first day of the week
        local firstDayTimestamp = now - secondsUntilFirstDay
        if not firstDayTimestamp then
            -- Handle the error (e.g., print an error message, log, or throw an exception)
            print("Error calculating first day timestamp")
            return nil
        end
        startpunkt = os.date("%Y%m%d000000", firstDayTimestamp)
    elseif (periode == 'MND') then
        startpunkt = os.date("%Y%m01000000")
    else
        print("Unknown periode:", periode)
        return nil
    end

    return startpunkt
end

function dagliglogg_ny()
-- Finne siste basert på tidspunkt - erstatning for last_insert_rowid?
-- select max(timestamp) from daglig 
-- Kanskje putte teksten fra denne inn i bruker prompt
    local respons, beskrivelse, spaceindex, timeformat, lengde
    local kontroll = false
    local rapportsummering = false
    local ukenr = nil
    local dato = nil

    db_dagliglogg = hs.sqlite3.open(db_dagliglogg_directory .. db_dagliglogg_file)

    previousapplication = hs.application.frontmostApplication()
    previouswindow = previousapplication:focusedWindow()

    local current_time = os.date("%Y%m%d%H%M%S")
    local last_time, errormessage = get_last_time(db_dagliglogg)
    if not last_time then
        print("Error:", errormessage)
        db_dagliglogg:close()
        return 
    end

    lastlengde, lasttext = get_last_lengde_text(db_dagliglogg, last_time)
    if not lastlengde then
        print("Error:", errormessage)
        db_dagliglogg:close()
        return 
    end
    if not lasttext then
        print("Error:", errormessage)
        db_dagliglogg:close()
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

    local used_time = time_diff_in_minutes(last_time, current_time)

    if (respons == "OK") then
        -- Remove all spaces in front and in end
        local firstword = nil
        local secondword = nil
        local beskrivelse = all_trim(beskrivelse)
        local uppertext = string.upper(beskrivelse)
        if (string.find(uppertext,' ') ~= nil) then
            firstword = string.sub(uppertext, 1, string.find(uppertext," ")-1)
            secondword = string.sub(uppertext, string.find(uppertext," ")+1, string.len(uppertext))
        else
            firstword = uppertext
        end

        if (tonumber(secondword) ~= nil) then
            if (string.len(secondword) == 6) then
                ukenr = secondword
            elseif (string.len(secondword) == 8) then
                dato = secondword
            end
        end

        if (string.find(kommandoer, firstword) ~= nil ) then
            kontroll = true
        end
        if (kontroll) then
            if (firstword == 'STOPP') then
                if (lastlengde == 0) then
                    db_dagliglogg:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. used_time .. " WHERE timestamp = '" .. last_time .. "' ")
                end
            elseif (firstword == 'EXPORT') then
                if ((secondword == nil) or (dato) or (secondword == 'DAG')) then
                    if (dato) then
                        fordato = os.time(time_from_string(dato))
                    else
                        fordato = os.time()
                    end
                    sluttdato = fordato + (60*60*24)
                    start = os.date("%Y%m%d000000", fordato )
                    if not start then
                        print("Error:", "Feil med dato_start")
                    end
-- Eksporterer dagens dag til fil med dagensdato
                    rapportsummering = true
                    rapportfilnavn = os.date("%Y%m%d.txt", fordato)
                    local success, error_message = get_report(db_dagliglogg, start, stopp, rapportsummering, rapportfilnavn)
                    if not success then
                        print("Error:", error_message)
                    end
                elseif ((secondword == 'UKE') or (ukenr)) then
-- Eksporterer denne uka til fil med denne ukenr
                    if (ukenr) then
                        startdato = getFirstDateOfWeek(string.sub(ukenr,1,4), string.sub(ukenr,5,6))
                    else
                        startdato = dato_start(secondword)
                    end
                    if not startdato then
                        print("Error:", "Feil med dato_start")
                    end
                    stoppdato = startdato + (60*60*24*7)
                    if not stoppdato then
                        print("Error:", "Feil med dato_start")
                    end
                    start = os.date("%Y%m%d000000", startdato )
                    stopp = os.date("%Y%m%d000000", stoppdato )
                    local rapportsummering = false
                    rapportfilnavn = os.date("%Yuke%W.txt")
                    local success, error_message = get_report(db_dagliglogg, start, stopp, rapportsummering, rapportfilnavn)
                    if not success then
                        print("Error:", error_message)
                    end
                elseif (secondword == 'MND') then
-- Eksporterer denne uka til fil med denne måneder
                    start = dato_start('MND')
                    if not start then
                        print("Error:", "Feil med dato_start")
                    end
                    local rapportsummering = false
                    rapportfilnavn = os.date("%Ymnd%m.txt")
                    local success, error_message = get_report(db_dagliglogg, start, rapportsummering, rapportfilnavn)
                    if not success then
                        print("Error:", error_message)
                    end
                end
            end
        else
            oppgave(db_dagliglogg, current_time, beskrivelse) 
        end
    end

    db_dagliglogg:close()

    previouswindow:focus()
end