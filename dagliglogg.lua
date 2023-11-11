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
-- db_dagliglogg:close()



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
    timestamp = os.date("%Y%m%d%H%M%S")
    if (respons == "OK") then
        -- Remove all spaces in front and in end
        text = all_trim(text)
        uppertext = string.upper(text)
        if (uppertext == 'STOPP') then
            last_rowid = db_dagliglogg:last_insert_rowid()
            if (last_rowid  ~= 0) then
                local stmt = db_dagliglogg:prepare("SELECT timestamp FROM daglig WHERE ROWID = ?")
                stmt:bind(1, last_rowid)
                stmt:step()
                local start = stmt:get_value(0)
                stmt:finalize()
                local diff = time_diff_in_minutes(start, timestamp)

                db_dagliglogg:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. diff .. " WHERE ROWID = " .. last_rowid .. " ")

            else
                local stmt = db_dagliglogg:prepare("SELECT max(timestamp) FROM daglig")
                stmt:step()
                local start = stmt:get_value(0)
                print(start)
                print(timestamp)
                stmt:finalize()
                local diff = time_diff_in_minutes(start, timestamp)

                db_dagliglogg:exec("UPDATE " .. db_dagliglogg_table .. " SET lengde = " .. diff .. " WHERE timestamp = '" .. start .. "' ")
   

                -- testCallbackFn = function(result) print("Callback Result: " .. result) end
                -- hs.focus()
                -- hs.dialog.alert(200, 200, testCallbackFn, "Daglig logg", "Last ROWID var 0 - ingen ting registrert", "OK")
            end
        elseif (uppertext == 'EXPORT') then
            
        else

            firstspaceindex = string.find(text, " ")

            -- Start with number
            test1 = string.sub(text,1,1)
            if (tonumber(test1) ~= nil) then
                -- Is last char in first work 'm' or 't'?
                timeformat = string.sub(text,firstspaceindex-1,firstspaceindex-1)
                if (timeformat == 'm') then
                    timeindex = 1
                    spaceindex = firstspaceindex - 1
                elseif (timeformat == 't') then
                    timeindex = 60
                    spaceindex = firstspaceindex - 1
                -- Default til minutter
                else
                    timeindex = 1
                end;
                tidsforbruk = string.sub(text,1,spaceindex-1)
                if (tonumber(tidsforbruk) ~= nil) then
                    lengde = tidsforbruk * timeindex
                else
                    lengde = 0
                end

                text = string.sub(text,firstspaceindex+1)
            else
                -- Ingen tid angitt
                lengde = 0
            end;

            db_dagliglogg:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES ('" .. timestamp .. "', " .. lengde .. ", '" .. text .. "')")
            
        end;
    end;
    -- db_dagliglogg:close()

    previouswindow:focus()
end