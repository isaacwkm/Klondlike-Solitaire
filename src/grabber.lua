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
--  Frame update
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
--  Called from love.mousepressed in main.lua
------------------------------------------------------------------------
function GrabberClass:beginDrag(x, y, cards)
  if self.heldObject then return end  -- already dragging

  local card = self:findTopCardAt(x, y, cards)
  if not card then return end         -- clicked empty space

  self.heldObject = card
  card.state      = 1                 -- “grabbed” (define states however you like)
  self.grabOffset = Vector(x, y) - card.position
end

------------------------------------------------------------------------
--  Called from love.mousereleased in main.lua
------------------------------------------------------------------------
-- grabber.lua  (add to endDrag)
function GrabberClass:endDrag(x, y, cards)
  if not self.heldObject then return end

  -- 1) snap Z-order: move grabbed card to end of draw list
  for i = #cards, 1, -1 do
    if cards[i] == self.heldObject then
      table.remove(cards, i)
      break
    end
  end
  table.insert(cards, self.heldObject)   -- now it draws on top

  -- 2) finalise state
  self.heldObject.state = CARD_STATE.IDLE
  self.heldObject       = nil
end


------------------------------------------------------------------------
--  Utility: find the topmost card under the cursor
--  (Assumes later cards in the array are rendered on top.)
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
