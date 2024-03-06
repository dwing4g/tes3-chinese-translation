-- luajit merge_topic.lua topicA.txt topicB.txt ... topicAB.txt

local io = io
local arg = arg

local topics, checkTopics = {}, {}
local err = 0

local function loadTopics(filename)
	io.stderr:write("loading ", filename, " ... ")
	local i = 1
	for line in io.lines(filename) do
		local topic, checkTopic, more = line:match "^%s*%[(.-)%]%s*=>%s*%[(.-)%](.*)$"
		topic = topic:lower()
		if not checkTopic:find "[\x80-\xff]" then
			checkTopic = checkTopic:lower()
		end
		if not topic or more:find "%S" then
			if err == 0 then io.stderr:write "\n" end
			io.stderr:write("ERROR: invalid topic file at line ", i, "\n")
			err = err + 1
		else
			if topics[topic] then
				if checkTopic ~= topic and topics[topic] ~= topic and topics[topic] ~= checkTopic then
					if err == 0 then io.stderr:write "\n" end
					io.stderr:write("ERROR: unmatched translation of topic [", topic, "] => [", topics[topic], "] [", checkTopic, "] at line ", i, "\n")
					err = err + 1
				end
				if topics[topic] == topic then
					topics[topic] = checkTopic
				end
			else
				topics[topic] = checkTopic
			end
			if checkTopics[checkTopic] then
				if checkTopic ~= topic and checkTopics[checkTopic] ~= topic then
					if err == 0 then io.stderr:write "\n" end
					io.stderr:write("ERROR: duplicated translation of checkTopic [", checkTopic, "] <= [", checkTopics[checkTopic], "] [", topic, "] at line ", i, "\n")
					err = err + 1
				end
			else
				checkTopics[checkTopic] = topic
			end
			i = i + 1
		end
	end
	io.stderr:write(i - 1, " topics\n")
end

for i = 1, #arg - 1 do
	loadTopics(arg[i])
end

if err == 0 then
	local ks = {}
	for topic in pairs(topics) do
		ks[#ks + 1] = topic
	end
	table.sort(ks)

	io.stderr:write("saving ", arg[#arg], " ... ")
	local f = io.open(arg[#arg], "wb")
	for _, topic in ipairs(ks) do
		f:write("[", topic, "] => [", topics[topic], "]\r\n")
	end
	f:close()
	io.stderr:write(#ks, " topics\n")
else
	print("ERROR: " .. err .. " errors")
end