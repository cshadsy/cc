local drives = {
    C = "/",       -- main system
    A = "/disk"    -- floppy or mounted disk
}

local currentDrive = "C"
local currentPath = "/"

local function setPath(drive, path)
    currentDrive = drive
    currentPath = path or "/"
    shell.setDir(drives[currentDrive])
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)

print("Starting MS-DOS...")
sleep(1)
print("HIMEM is testing extended memory...done.")
sleep(1)
print("")

local function printPrompt()
    term.write(currentDrive .. ":\\" .. shell.dir():gsub("^" .. drives[currentDrive], "") .. "> ")
end

local function listDir(path)
    local absPath = fs.combine(drives[currentDrive], path or "")
    local files = fs.list(absPath)
    for _, file in ipairs(files) do
        local fullPath = fs.combine(absPath, file)
        if fs.isDir(fullPath) then
            print("<DIR>       " .. file)
        else
            print("            " .. file)
        end
    end
end

local function changeDir(path)
    if currentDrive == "A" then
        print("Access denied: Cannot change directory on drive A:")
        return
    end
    local target = fs.combine(shell.dir(), path)
    if fs.exists(target) and fs.isDir(target) then
        shell.setDir(target)
    else
        print("Invalid directory")
    end
end

local function readFile(path)
    local target = fs.combine(shell.dir(), path)
    if not fs.exists(target) or fs.isDir(target) then
        print("File not found")
        return
    end
    local file = fs.open(target, "r")
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
        listDir(shell.dir())
    elseif cmd == "cd" then
        if arg1 then
            changeDir(arg1)
        else
            print(shell.dir())
        end
    elseif cmd == "type" then
        if arg1 then
            readFile(arg1)
        else
            print("Specify file to read")
        end
    elseif cmd == "a:" or cmd == "c:" then
        local driveLetter = cmd:sub(1,1):upper()
        if fs.exists(drives[driveLetter]) then
            setPath(driveLetter)
        else
            print("Drive " .. driveLetter .. ": not ready")
        end
    elseif cmd ~= "" then
        local resolved = shell.resolveProgram(cmd)
        if resolved then
            shell.run(cmd, table.unpack(args, 2))
        else
            print("'" .. cmd .. "' is not recognized as an internal or external command.")
        end
    end
end
