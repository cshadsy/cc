term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)

print("Energy Star® Compliance Notice")
print("This device complies with part 15 of the Minecraftian Code.")
print("Operation is subject to the following two conditions:")
print(" (1) This device may not cause harmful interference, and")
print(" (2) This device must accept any interference received.")
print("")
sleep(2)

local w, h = term.getSize()
local title = "MINECRAFTIAN MEGATRENDS"
local frameTop = "+" .. string.rep("-", w - 2) .. "+"
local frameBottom = frameTop
local frameMid = "|" .. string.rep(" ", w - 2) .. "|"

term.setTextColor(colors.gray)
print(frameTop)
for i = 1, 3 do
    print(frameMid)
end

local titlePos = math.floor((w - #title) / 2)
term.setCursorPos(titlePos + 1, 5)
term.setTextColor(colors.yellow)
print(title)
term.setTextColor(colors.gray)

for i = 1, 3 do
    print(frameMid)
end
print(frameBottom)
term.setTextColor(colors.white)

sleep(1)
print("")
print("Detecting connected hardware...\n")
sleep(1)

for _, side in ipairs({"left", "right", "top", "bottom", "front", "back"}) do
    if peripheral.isPresent(side) then
        local type = peripheral.getType(side)
        print("[" .. side:upper() .. "] -> " .. type)
        sleep(0.3)
    end
end

print("\nBooting CraftOS...")
sleep(2)
shell.run("shell")
