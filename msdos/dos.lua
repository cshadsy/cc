local drives = {
    C = "/",       -- main system
    A = "/disk"    -- floppy or mounted disk
}

local currentDrive = "C"
local currentPath = "/"

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)

print("Starting MS-DOS...")
sleep(1)
print("HIMEM is testing extended memory...done.")
sleep(1)
print("")

local function getAbsolutePath(relativePath)
    return fs.combine(drives[currentDrive], fs.combine(currentPath, relativePath))
end

local function printPrompt()
    local displayPath = currentPath:gsub("^/", ""):gsub("/", "\\")
    if displayPath == "" then displayPath = "" end
    term.write(currentDrive .. ":\\" .. displayPath .. "> ")
end

local function listDir(path)
    local absPath = getAbsolutePath(path or "")
    if not fs.exists(absPath) then
        print("Path not found")
        return
    end
    local files = fs.list(absPath)
    for _, file in ipairs(files) do
        local full = fs.combine(absPath, file)
        if fs.isDir(full) then
            print("<DIR>       " .. file)
        else
            print("            " .. file)
        end
    end
end

local function changeDir(path)
    if not path then
        print(currentPath)
        return
    end

    local target
    if path == ".." then
        if currentPath == "/" then
            print("Invalid directory")
            return
        end
        target = fs.getDir(currentPath)
        if target == "" then target = "/" end
    else
        target = fs.combine(currentPath, path)
    end

    -- Prevent access to /disk from C:\
    if currentDrive == "C" and target:match("^disk") then
        print("Invalid directory")
        return
    end

    local absTarget = fs.combine(drives[currentDrive], target)
    if fs.exists(absTarget) and fs.isDir(absTarget) then
        currentPath = fs.combine("/", target)
    else
        print("Invalid directory")
    end
end

local function readFile(filename)
    local absPath = getAbsolutePath(filename)
    if not fs.exists(absPath) or fs.isDir(absPath) then
        print("File not found")
        return
    end
    local file = fs.open(absPath, "r")
    local line = file.readLine()
    while line do
        print(line)
        line = file.readLine()
    end
    file.close()
end

while true do
    printPrompt()
    local input = read()
    local args = {}
    for word in string.gmatch(input, "[^%s]+") do
        table.insert(args, word)
    end

    local cmd = args[1] and args[1]:lower() or ""
    local arg1 = args[2]

    if cmd == "exit" then
        break
    elseif cmd == "cls" then
        term.clear()
        term.setCursorPos(1,1)
    elseif cmd == "dir" then
        listDir(currentPath)
    elseif cmd == "cd" then
        changeDir(arg1)
    elseif cmd == "type" then
        if arg1 then
            readFile(arg1)
        else
            print("Specify file to read")
        end
    elseif cmd == "a:" or cmd == "c:" then
        local driveLetter = cmd:sub(1,1):upper()
        if fs.exists(drives[driveLetter]) then
            currentDrive = driveLetter
            currentPath = "/"
        else
            print("Drive " .. driveLetter .. ": not ready")
        end
    elseif cmd ~= "" then
        local absPath = getAbsolutePath(cmd)
        if fs.exists(absPath) then
            shell.run(absPath, table.unpack(args, 2))
        elseif shell.resolveProgram(cmd) then
            shell.run(cmd, table.unpack(args, 2))
        else
            print("'" .. cmd .. "' is not recognized as an internal or external command.")
        end
    end
end
