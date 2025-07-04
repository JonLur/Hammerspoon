choices={}
--local choices = {
--  {["text"]="heroringvinge;Coenonympha hero"},
--  {["text"]="gullringvinge;Aphantopus hyperantus"},
--  {["text"]="engringvinge;Coenonympha pamphilus"},
--  }

local function trim(s)
   return s:match "^%s*(.-)%s*$"
end

local function readFile(filename)
  local file = io.open(filename, "r")
  local lest = file:read("*a")
  file:close()
  return lest
end

local function readArterFileToSQL( db, arter)
  local sqlmemstmt = db:prepare("INSERT INTO arter (artsnavn) VALUES (?)")
  local x, a, b = 1;
  while x < string.len(arter) do
    a, b = string.find(arter, '.-\n', x);
    if not a then
      break
    else
      sqlmemstmt:bind_values(trim(string.sub(arter,a,b)))
      sqlmemstmt:step()
      sqlmemstmt:reset()
    end
    x = b + 1
  end
  sqlmemstmt:finalize()
end

local function moveArterSQLToSQL( db1, db2 )
  local sqlfilestmt = db2:prepare("INSERT INTO arter (artsnavn) VALUES (?)")
  for nrow in db1:nrows("SELECT artsnavn FROM arter ORDER BY artsnavn") do
    sqlfilestmt:bind_values(nrow.artsnavn)
    sqlfilestmt:step()
    sqlfilestmt:reset()
  end
  sqlfilestmt:finalize()
  -- db1:close()
  -- db2:close()
end


function sendTastDown()
  hs.eventtap.keyStroke(nil,"down")
end
function sendTastEnter()
  hs.eventtap.keyStroke(nil,"return")
end


-- Timestamp "modification"
artsnavnTXT = "/Users/jon/Documents/Artsjakt/artsnavn.txt"
artsnavnDB = "/Users/jon/Documents/Artsjakt/artsnavn.sqlite3"
local timestampTXT = hs.fs.attributes(artsnavnTXT, 'modification')
local timestampDB = hs.fs.attributes(artsnavnDB, 'modification')
if timestampDB == nil then
  timestampDB = 0
end

if timestampTXT > timestampDB then

  local allearter = readFile(artsnavnTXT)

  local dbmem = hs.sqlite3.open_memory()
  local sqlcreate = "CREATE TABLE arter(id INTEGER PRIMARY KEY, artsnavn TEXT)"
  dbmem:exec(sqlcreate)

  readArterFileToSQL( dbmem, allearter )

  local dbfile = hs.sqlite3.open(artsnavnDB)
  sqldrop = "DROP TABLE arter"
  dbfile:exec(sqldrop)
  sqlcreate = "CREATE TABLE arter(id INTEGER PRIMARY KEY, artsnavn TEXT)"
  dbfile:exec(sqlcreate)

  moveArterSQLToSQL( dbmem, dbfile )

  dbmem:close()
  dbfile:close()

end

db = hs.sqlite3.open(artsnavnDB)
for nrow in db:nrows("SELECT artsnavn FROM arter") do
  choices[#choices+1]={["text"]=nrow.artsnavn}
end
db:close()

-- Create the chooser.
function chooserFunction(choices)
  if (choices) then
    local valgt = choices["text"]
    hs.pasteboard.setContents(valgt)
    hs.eventtap.rightClick(hs.mouse.getAbsolutePosition())
    hs.timer.doAfter(.25,sendTastDown)
    hs.timer.doAfter(.25,sendTastEnter)
    if not valgt.match(valgt,"ubestemt;") then
      hs.eventtap.keyStroke({},"tab")
    end
  end
  local hammer=hs.application.get("Hammerspoon")
  hammer:hide()
end

chooser = hs.chooser.new(chooserFunction)

function showChooser()
  chooser:show()
end

chooser:searchSubText(true)
chooser:choices(choices)

hs.hotkey.bind({"ctrl", "alt"}, "B", "Artsnavn", showChooser)