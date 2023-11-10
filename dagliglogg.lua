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



function dagliglogg_ny()
    local respons, text, tmp1
    db_dagliglogg = hs.sqlite3.open(db_dagliglogg_file)
    respons, text = hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK", "Cancel")
    if (respons == "OK") then
        tmp1 = string.find(text, " ")
        string.sub(text,tmp1-1,1)
        4	4
        
        > string.sub(x,0,3) 
        db_dagliglogg:exec("INSERT INTO " .. db_dagliglogg_table .. " (timestamp, lengde, text) VALUES (DateTime(), 0, '" .. text .. "')")
    end;
    db_dagliglogg:close()
end

-- Opens a file in read mode
--file = io.open("/Users/jon/Documents/Artsjakt/artsnavn.txt", "r")
--allearter=file:read("*a")
--file:close()

--function trim(s)
--   return s:match "^%s*(.-)%s*$"
--end

--local x, a, b = 1;
--while x < string.len(allearter) do
--  a, b = string.find(allearter, '.-\n', x);
--  if not a then
--    break;
--  else
--    choices[#choices+1]={["text"]=trim(string.sub(allearter,a,b))}
--  end;
--  x = b + 1;
--end;

--table.sort(choices, function(a,b) en=a["text"] to=b["text"] return en<to end )

--function sendTastDown()
--  hs.eventtap.keyStroke(nil,"down")
--end
--function sendTastEnter()
--  hs.eventtap.keyStroke(nil,"return")
--end


--chooser = hs.chooser.new(chooserFunction)

--chooser:showCallback(function() darktablewindow=hs.window.frontmostWindow()  end )

--function showChooser()
--  chooser:show()
--end

--chooser:searchSubText(true)
--chooser:choices(choices)

--hs.hotkey.bind({"ctrl", "alt"}, "B", "Artsnavn", showChooser)
