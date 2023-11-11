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
    local startpunkt = "FEIL"

    if (periode == "EXPORT") then
        startpunkt = os.date("%Y%m%d000000")
    elseif (periode == "EXPORT DAG") then
        startpunkt = os.date("%Y%m%d000000")
    elseif (periode == "EXPORT UKE") then
-- Function to calculate the first day of the week
        local now = os.time()
        local currentDayOfWeek = tonumber(os.date("%w", now))
-- Calculate seconds until the first day of the week (Monday)
        local secondsUntilFirstDay = (currentDayOfWeek - 1) * 24 * 60 * 60
-- Calculate the timestamp for the first day of the week
        local firstDayTimestamp = now - secondsUntilFirstDay
        startpunkt = os.date("%Y%m%d000000", firstDayTimestamp)
    elseif (periode == "EXPORT MND") then
        startpunkt = os.date("%Y%m01000000")
    end

    return startpunkt
end

function dagliglogg_ny()
-- Finne siste basert på tidspunkt - erstatning for last_insert_rowid?
-- select max(timestamp) from daglig 
-- Kanskje putte teksten fra denne inn i bruker prompt
    local respons, beskrivelse, spaceindex, timeformat, lengde

    db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)

    previousapplication = hs.application.frontmostApplication()
    previouswindow = previousapplication:focusedWindow()

    hs.focus()
    respons, beskrivelse = hs.dialog.textPrompt("Daglig logg", "Hva har du gjort nå?", "Start gjerne med minutter.", "OK", "Cancel")
    
    local current_time = os.date("%Y%m%d%H%M%S")
    local last_time = get_last_time(db_dagliglogg)
    local used_time = time_diff_in_minutes(last_time, current_time)

    if (respons == "OK") then
        -- Remove all spaces in front and in end
        local beskrivelse = all_trim(beskrivelse)
        local uppertext = string.upper(beskrivelse)

        if (uppertext == 'STOPP') then
            db_dagliglogg:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. used_time .. " WHERE timestamp = '" .. last_time .. "' ")
        elseif (uppertext == 'EKSPORT') then
-- Eksporterer dagens dag til fil med dagensdato
            start = dato_start('EKSPORT')
        elseif (uppertext == 'EKSPORT DAG') then
-- Eksporterer dagens dag til fil med dagensdato
            start = dato_start('EKSPORT DAG')
        elseif (uppertext == 'EKSPORT UKE') then
-- Eksporterer denne ukaa til fil med denne ukenr
            start = dato_start('EKSPORT UKE')
        elseif (uppertext == 'EKSPORT MND') then
-- Eksporterer denne ukaa til fil med denne måneder
            start = dato_start('EKSPORT MND')
        else
           oppgave(db_dagliglogg, current_time, beskrivelse) 
        end;
    end;

    db_dagliglogg:close()

    previouswindow:focus()
end