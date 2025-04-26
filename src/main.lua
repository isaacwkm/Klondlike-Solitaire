-- Isaac Kim
-- CMPM 121 – Pickup
-- 04-11-25
io.stdout:setvbuf("no")

require "card"
require "grabber"

-- ---------------------------------------------------------------------------
--  Global-ish game table (keeps things out of the true global namespace)
-- ---------------------------------------------------------------------------
local game = {
  grabber = nil,   -- will hold a GrabberClass instance
  cards   = {}     -- array of CardClass instances
}

-- ---------------------------------------------------------------------------
--  LOVE callbacks
-- ---------------------------------------------------------------------------
function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  game.grabber = GrabberClass:new()

  -- temp demo card
  table.insert(game.cards, CardClass:new(100, 100))
end

-- small helper so update() stays tidy
local function checkForMouseOver()
  if not game.grabber.currentMousePos then
    return
  end
  for _, card in ipairs(game.cards) do
    card:checkForMouseOver(game.grabber)
  end
end

function love.update(dt)
  game.grabber:update(dt)

  for _, card in ipairs(game.cards) do
    card:update(dt)
  end

  checkForMouseOver()
end

function love.draw()
  for _, card in ipairs(game.cards) do
    card:draw()
  end

  love.graphics.setColor(1, 1, 1, 1)
  local mx, my = game.grabber.currentMousePos.x, game.grabber.currentMousePos.y
  love.graphics.print(("Mouse: %.0f, %.0f"):format(mx, my), 10, 10)
end

function love.mousepressed(x, y, button)
  if button == 1 then
    -- pass the card list so Grabber can decide what (if anything) it grabbed
    game.grabber:beginDrag(x, y, game.cards)
  end
end

function love.mousereleased(x, y, button)
  if button == 1 then
    game.grabber:endDrag(x, y)
  end
end
