-- grabber.lua
-- Represents the “hand” / mouse pointer for dragging cards.

require "vector"

GrabberClass = {}

function GrabberClass:new()
  local g = {
    currentMousePos = Vector(),
    previousMousePos = Vector(),
    heldObject      = nil,     -- Card being dragged (or nil)
    grabOffset      = Vector() -- Offset between mouse and card’s local origin
  }
  return setmetatable(g, { __index = GrabberClass })
end

------------------------------------------------------------------------
--  update
------------------------------------------------------------------------
function GrabberClass:update(dt)
  self.previousMousePos = self.currentMousePos
  self.currentMousePos  = Vector(love.mouse.getX(), love.mouse.getY())

  -- If we’re holding a card, move it so its origin stays at the same
  -- offset from the cursor that it had when we first clicked.
  if self.heldObject then
    self.heldObject.position = self.currentMousePos - self.grabOffset
  end
end

------------------------------------------------------------------------
--  Calls from love.mousepressed in main.lua
------------------------------------------------------------------------
function GrabberClass:beginDrag(x, y, piles)
  if self.heldObject then return end

  -- search each pile for a card
  for _, pile in ipairs(piles) do
    local card = pile:findTopCardAt(x, y)
    if card then
      self.heldObject = card
      card.state = CARD_STATE.GRABBED
      self.grabOffset = Vector(x, y) - card.position
      break
    end
  end
end


------------------------------------------------------------------------
--  Calls from love.mousereleased in main.lua
------------------------------------------------------------------------

function GrabberClass:endDrag(x, y, piles)
  if not self.heldObject then return end

  -- Find nearest pile
  local closestPile = nil
  local closestDist = math.huge

  for _, pile in ipairs(piles) do
    local dist = math.sqrt((pile.position.x - x)^2 + (pile.position.y - y)^2)
    if dist < closestDist then
      closestDist = dist
      closestPile = pile
    end
  end

  -- Snap into the closest pile
  if closestPile then
    closestPile:addCard(self.heldObject)
  end

  self.heldObject.state = CARD_STATE.IDLE
  self.heldObject = nil
end

------------------------------------------------------------------------
--  Finds the topmost card under the cursor
------------------------------------------------------------------------
function GrabberClass:findTopCardAt(x, y, cards)
  for i = #cards, 1, -1 do
    local c = cards[i]
    if c:containsPoint(x, y) then
      return c
    end
  end
  return nil
end
