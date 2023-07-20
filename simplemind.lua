function sendAddSiblingTopic()
  hs.eventtap.keyStroke({"shift", "command"},"return")
end

function sendProgramStreng()
  local s
  s = ProgramStreng .. "\r"
  hs.eventtap.keyStrokes(s)
end

function atomtilsimplemind()
  local k,v

  program={}

  -- Opens a file in read mode
  programfil = io.open("/Users/jon/Documents/mdg-program-punkter.txt", "r")
  allepunkter=programfil:read("*a")
  programfil:close()

  local x, a, b = 1;
  while x < string.len(allepunkter) do
    a, b = string.find(allepunkter, '.-\n', x);
    if not a then
      break;
    else
      program[#program+1]={["text"]=trim(string.sub(allepunkter,a,b))}
    end;
    x = b + 1;
  end;

  hs.application.launchOrFocus("SimpleMind.app")
  --hs.timer.doAfter(.25,sendAddSiblingTopic)
  hs.eventtap.keyStroke({}, "return")

  --for qwerty in pairs(program) do print(qwerty["text"]) end
  local i = 1
  while program[i] do
    os.execute("sleep " .. tonumber(0.2))
    hs.eventtap.keyStrokes(program[i]["text"])
    hs.eventtap.keyStroke({}, "return")
    print(program[i]["text"])
    os.execute("sleep " .. tonumber(0.2))
    sendAddSiblingTopic()
    i = i + 1
  end

end
