-- This program makes a turtle run down the specified path until it encounters a box or wall, then it stops.
-- If it stops next to a chest it will dump its contents (sans the chest in slot 1) and run back from where
-- it started.


--[[**********************
       FUNCTIONS
  **********************]]--

-- clears the screen
function Clear()
  term.clear()
  term.setCursorPos(1,1)
end

-- Sets the turlte up to point in the right direction.
-- Returns the new direction the turtle should go in.
function ConfirmDir(direction)
  if direction == 'F' then
    return 'F'
  elseif direction == 'B' then
    -- turn around then set to go forward
    turtle.turnLeft()
    turtle.turnLeft()
    return 'F'
  elseif direction == 'L' then
    turtle.turnLeft()
    return 'F'
  elseif direction == 'R' then
    turtle.turnRight()
    return 'F'
  elseif direction == 'U' then
    return 'U'
  elseif direction == 'D' then
    return 'D'
  end
end

-- moves the turtle in the direction specified
function Move(direction)
  if direction == 'F' then
    turtle.forward()
  elseif direction == 'B' then
    turtle.back()
  elseif direction == 'L' then
    turtle.left()
  elseif direction == 'R' then
    turtle.turnRight()
  elseif direction == 'U' then
    turtle.up()
  elseif direction == 'D' then
    turtle.down()
  end
end

-- Turns the turtle to reverse the direction
function Turn(direction)
  if direction == 'B' then
    turtle.turnRight()
    turtle.turnRight()
  elseif direction == 'L' then
    turtle.turnLeft()
  elseif direction == 'R' then
    turtle.turnRight()
  end
end

-- Reverses the direction of the turtle
function ReverseDir(direction)
  if direction == 'F' then
    return 'B'
  elseif direction == 'B' then
    return 'F'
  elseif direction == 'L' then
    return 'R'
  elseif direction == 'R' then
    return 'L'
  elseif direction == 'U' then
    return 'D'
  elseif direction == 'D' then
    return 'U'
  end
end

-- Detects given a location of travel
function Detect(direction)
  if direction == 'F' then
    return turtle.detect()
  elseif direction == 'U' then
    return turtle.detectUp()
  elseif direction == 'D' then
    return turtle.detectDown()
  else
    print("ERROR: Invalid Detect direction.")
    return false
  end
end

-- Returns true if chest is found within the vicinity
function ChestFound(direction)
  -- Move to 1 where our chest is
  turtle.select(1)
  
  if direction == 'F' then
    -- We have to use this because the stupid turtle will be in the wrong direction if we don't complete this cycle
    found = false
    
    if turtle.compare() then
      found = 'F'
    end
    
    if turtle.compareUp() then
      found = 'U'
    end
    
    if turtle.compareDown() then
      found = 'D'
    end

    
    --turn right and check
    turtle.turnRight()
    if turtle.compare() then
      found = 'R'
    end
    
    -- turn around and check
    turtle.turnRight()
    turtle.turnRight()
    if turtle.compare() then
      found = 'L'
    end
    
    -- back to inital position
    turtle.turnRight()
    
     -- return result
    return found
  
  elseif direction == 'U' or direction == 'D'then
    found = false
    
    if turtle.compare() then
      found = 'F'
    end
    
    if turtle.compareUp() then
      found = 'U'
    end
    
    if turtle.compareDown() then
      found = 'D'
    end
    
    -- turn then check
    turtle.turnRight()
    if turtle.compare() then
      found = 'R'
    end
    
    -- turn then check
    turtle.turnRight()
    if turtle.compare() then
      found = 'B'
    end
    
    -- turn then check
    turtle.turnRight()
    if turtle.compare() then
      found = 'L'
    end
    
    -- back to initial
    turtle.turnRight()
    
    -- return result
    return found
  
    else
      print("ERROR: Invalid ChestFound direction.")
      return false
  end 
  
end

--[[**********************
       END FUNCTIONS
  **********************]]--

-- init clear
Clear()


-- Check there's a chest (as best we can) in slot 1
while turtle.getItemCount(1) < 1 do
  print("Put a chest in slot 1 before starting.")
  print("Press enter to continue or q to quit.")
  if string.upper(io.read()) == 'Q' then
    Clear()
    return
  end
end

-- Ask the user what direction to go in
Clear()
dir = nil
invalid = true
while invalid do

    -- what direction to go?
    print("What direction to go in?")
    print("(F/B/L/R/U/D)")
    paths = {"F", "B", "L", "R", "U", "D"}
    dir = string.upper(io.read())
    
    -- see if the dir is a path
    for i, d in ipairs(paths) do
      if dir == d then
        invalid = false
      end
    end
    
    -- Display warning if we're invalid
    if invalid == true then
      print("Invalid option: " .. dir)
    end
end

-- init the turtle's direction
dir = ConfirmDir(dir)

-- Start the main loop in search of a chest
foundChest = false
chestLocation = false
steps = 0
while not foundChest do
  -- Do we see a roadblock?
  if Detect(dir) then
    -- end of the line, there's a roadblock
    break
  end
  
  -- good to go, advance
  Move(dir)
  steps = steps + 1
  
  -- Do we see a chest?
  chestLocation = false
  chestLocation = ChestFound(dir)
  if not (chestLocation == false) then
    -- a chest has been found, get out!
    foundChest = true
    break;
  end
  
end

-- if we didn't find the chest it means we hit a wall, stop the program
if not foundChest then
  print('Did not find the chest. Exiting...')
  print(' ')
  return 
end

-- turn to face the chest
Turn(chestLocation)

-- Dump the cargo except for #1
for i = 2, 16 do
  turtle.select(i)
  while turtle.getItemCount(i) > 0 do
    if chestLocation == 'U' then
      turtle.dropUp(turtle.getItemCount(i))
    elseif chestLocation == 'D' then
      turtle.dropDown(turtle.getItemCount(i))
    else
      turtle.drop(turtle.getItemCount(i))
    end
  end
end

-- Turn back to initial direction
Turn(ReverseDir(chestLocation))

-- Move back to start
while steps > 0 do
  Move(ReverseDir(dir))
  steps = steps - 1
end

print('DONE!')

return