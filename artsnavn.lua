local choices={}
--local choices = {
--  {["text"]="heroringvinge;Coenonympha hero"},
--  {["text"]="gullringvinge;Aphantopus hyperantus"},
--  {["text"]="engringvinge;Coenonympha pamphilus"},
--  }

-- Opens a file in read mode
file = io.open("/Users/jon/Documents/Artsjakt/artsnavn.txt", "r")
allearter=file:read("*a")
file:close()

function trim(s)
   return s:match "^%s*(.-)%s*$"
end

local x, a, b = 1;
while x < string.len(allearter) do
  a, b = string.find(allearter, '.-\n', x);
  if not a then
    break;
  else
    choices[#choices+1]={["text"]=trim(string.sub(allearter,a,b))}
  end;
  x = b + 1;
end;

table.sort(choices, function(a,b) en=a["text"] to=b["text"] return en<to end )

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
