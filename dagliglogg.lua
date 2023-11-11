-- Database format:
-- timestamp - DateTime()
-- lengde - integer hentet fra slutten av tekst som er lagt inn
-- text - string

db_dagliglogg = nil
db_dagliglogg_file = "/Users/jon/Documents/DagligLogg/dagliglogg.sqlite3"
db_dagliglogg_table = "daglig"

-- sqlite3.open - open if exists - creates if not
-- create table if not exists TableName (col1 typ1, ..., colN typN)
-- db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)
-- currdir = hs.fs.currentDir()
-- result = hs.fs.chdir(db_dagliglogg_dir)
db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)
db_dagliglogg:exec("CREATE TABLE IF NOT EXISTS " .. db_dagliglogg_table .. " (timestamp STRING, lengde INTEGER, text STRING)")
-- db_dagliglogg:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES (DateTime(), 11, 'test1')")
-- hs.fs.chdir(currdir)
db_dagliglogg:close()


function get_last_time(db)
-- Error handling should be added

    local stmt = db:prepare("SELECT max(timestamp) FROM daglig")
    stmt:step()
    local max_time = stmt:get_value(0)
    stmt:finalize()

    return max_time
end

function get_time_index(word)
    local length_word = string.len(word)
    local timeformat = string.sub(word,length_word-1,length_word-1)
    local timeindex = 1
    if (tonumber(timeformat) ~= nil) then
        if (timeformat == 'm') then
            timeindex = 1
            spaceindex = first_word - 1
        elseif (timeformat == 't') then
            timeindex = 60
            spaceindex = first_word - 1
        else
            timeindex = 1
        end
    end
    return timeindex
end

function oppgave(db)
    local used_time = 0
    local first_word_index = string.find(text, " ")
    local first_word = string.sub(text,first_word_index-1,first_word_index-1)

    -- Start with number
    local is_number = string.sub(text,1,1)
    if (tonumber(is_number) ~= nil) then
        -- Is last char in first word 'm' or 't'?
        local time_index = get_time_index(first_word)
       
        tidsforbruk = string.sub(text,1,spaceindex-1)
        if (tonumber(tidsforbruk) ~= nil) then
            used_time = tidsforbruk * timeindex
        else
            used_time = 0
        end

        text = string.sub(text,firstspaceindex+1)
    else
        -- Ingen tid angitt
        used_time = 0
    end;

    db:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES ('" .. current_time .. "', " .. used_time .. ", '" .. text .. "')")
end


function dagliglogg_ny()
-- Finne siste basert på tidspunkt - erstatning for last_insert_rowid?
-- select max(timestamp) from daglig 
-- Kanskje putte teksten fra denne inn i bruker prompt
    local respons, text, spaceindex, timeformat, lengde

    previousapplication = hs.application.frontmostApplication()
    previouswindow = previousapplication:focusedWindow()

    -- db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)
    -- hs.application.launchOrFocus("Hammerspoon")
    hs.focus()
    respons, text = hs.dialog.textPrompt("Daglig logg", "Hva har du gjort nå?", "Start gjerne med minutter.", "OK", "Cancel")
    
    local current_time = os.date("%Y%m%d%H%M%S")
    local last_time = get_last_time(db_dagliglogg)
    local used_time = time_diff_in_minutes(last_time, current_time)

    if (respons == "OK") then
        -- Remove all spaces in front and in end
        text = all_trim(text)
        uppertext = string.upper(text)
        if (uppertext == 'STOPP') then
            db_dagliglogg:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. used_time .. " WHERE timestamp = '" .. last_time .. "' ")
        elseif (uppertext == 'EXPORT') then
            
        else
           oppgave(db_dagliglogg) 
        end;
    end;
    -- db_dagliglogg:close()

    previouswindow:focus()
end