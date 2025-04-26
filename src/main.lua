-- Isaac Kim
-- CMPM 121 – Pickup
-- 04-11-25
io.stdout:setvbuf("no")

require "card"
require "grabber"

-- ---------------------------------------------------------------------------
--  Singleton game tables
-- ---------------------------------------------------------------------------
local game = {
  grabber = nil, -- will hold a GrabberClass instance
  cards   = {}   -- array of CardClass instances
}

game.snapPoints = {
  Vector(200, 200),
  Vector(300, 200),
  Vector(400, 200),
  Vector(500, 200),
}

-- ---------------------------------------------------------------------------
--  LOVE methods
-- ---------------------------------------------------------------------------
function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  game.grabber = GrabberClass:new()

  -- temp demo card
  table.insert(game.cards, CardClass:new(100, 100))
end

function love.update(dt)
  -- move the grabber first (updates mouse pos)
  game.grabber:update(dt)

  -- cursor data for hover tests
  local mx, my   = game.grabber.currentMousePos.x, game.grabber.currentMousePos.y
  local dragging = (game.grabber.heldObject ~= nil)

  -- update each card, then refresh its visual state
  for _, card in ipairs(game.cards) do
    card:update(dt)
    card:updateHoverState(mx, my, dragging)
  end
end

function love.draw()
  -- draw snap points
  love.graphics.setColor(1, 0, 0, 0.5)

  for _, point in ipairs(game.snapPoints) do
    love.graphics.circle("fill", point.x, point.y, 8)
  end
  love.graphics.setColor(1, 1, 1, 1) -- reset color


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
    game.grabber:endDrag(x, y, game.cards, game.snapPoints)
  end
end
