local choices={}
--local choices = {
--  {["text"]="heroringvinge;Coenonympha hero"},
--  {["text"]="gullringvinge;Aphantopus hyperantus"},
--  {["text"]="engringvinge;Coenonympha pamphilus"},
--  }

function trim(s)
   return s:match "^%s*(.-)%s*$"
end

-- Timestamp "modification"
artsnavnTXT = "/Users/jon/Documents/Artsjakt/artsnavn.txt"
artsnavnDB = "/Users/jon/Documents/Artsjakt/artsnavn.sqlite3"
timestampTXT = hs.fs.attributes(artsnavnTXT, 'modification')
timestampDB = hs.fs.attributes(artsnavnDB, 'modification')
if timestampDB == nil then
  timestampDB = 0
end

if timestampTXT > timestampDB then
  file = io.open(artsnavnTXT, "r")
  allearter=file:read("*a")
  file:close()

  -- db = hs.sqlite3.open(artsnavnDB)
  dbmem = hs.sqlite3.open_memory()
  -- sqldrop = "DROP TABLE arter"
  -- db:exec(sqldrop)
  sqlcreate = "CREATE TABLE arter(id INTEGER PRIMARY KEY, artsnavn TEXT)"
  dbmem:exec(sqlcreate)

  local sqlmemstmt = dbmem:prepare("INSERT INTO arter (artsnavn) VALUES (?)")

  local x, a, b = 1;
  while x < string.len(allearter) do
    a, b = string.find(allearter, '.-\n', x);
    if not a then
      break;
    else
      sqlmemstmt:bind_values(trim(string.sub(allearter,a,b)))
      sqlmemstmt:step()
      sqlmemstmt:reset()
    end;
    x = b + 1;
  end;

  sqlmemstmt:finalize()


  local dbfile = hs.sqlite3.open(artsnavnDB)
  sqldrop = "DROP TABLE arter"
  dbfile:exec(sqldrop)
  sqlcreate = "CREATE TABLE arter(id INTEGER PRIMARY KEY, artsnavn TEXT)"
  dbfile:exec(sqlcreate)

  local sqlfilestmt = dbfile:prepare("INSERT INTO arter (artsnavn) VALUES (?)")

  for nrow in dbmem:nrows("SELECT artsnavn FROM arter ORDER BY artsnavn") do
      sqlfilestmt:bind_values(nrow.artsnavn)
      sqlfilestmt:step()
      sqlfilestmt:reset()
  end
  sqlfilestmt:finalize()
  dbmem:close()
  dbfile:close()
end;

db = hs.sqlite3.open(artsnavnDB)
-- Les data med prepare
for nrow in db:nrows("SELECT artsnavn FROM arter") do
  choices[#choices+1]={["text"]=nrow.artsnavn}
end
-- Lukk databasen
db:close()

-- table.sort(choices, function(a,b) en=a["text"] to=b["text"] return en<to end )

function sendTastDown()
  hs.eventtap.keyStroke(nil,"down")
end
function sendTastEnter()
  hs.eventtap.keyStroke(nil,"return")
end
-- Create the chooser.
function chooserFunction(choices)
  if (choices) then
    local valgt = choices["text"]
    --local test = hs.eventtap.new({hs.eventtap.event.types.keyDown})
    --hs.application.open("darktable")
    --hs.eventtap.keyStrokes(choices["text"])
    hs.pasteboard.setContents(valgt)
    hs.eventtap.rightClick(hs.mouse.getAbsolutePosition())
    hs.timer.doAfter(.25,sendTastDown)
    hs.timer.doAfter(.25,sendTastEnter)
    --hs.eventtap.keyStroke({},"tab")
    --hs.eventtap.keyStrokes('test')
    --test.keyStrokes("test")
    if not valgt.match(valgt,"ubestemt;") then
      hs.eventtap.keyStroke({},"tab")
    end
  end
  -- chooserInProgress=true
  local hammer=hs.application.get("Hammerspoon")
  hammer:hide()
end

chooser = hs.chooser.new(chooserFunction)

--chooser:showCallback(function() darktablewindow=hs.window.frontmostWindow()  end )

function showChooser()
  chooser:show()
end

chooser:searchSubText(true)
chooser:choices(choices)

hs.hotkey.bind({"ctrl", "alt"}, "B", "Artsnavn", showChooser)
