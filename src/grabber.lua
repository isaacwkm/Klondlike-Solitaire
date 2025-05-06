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
  for _, pile in ipairs(piles) do
    -- Only grab the top card of any pile
    local topCard = pile.cards[#pile.cards]
    if topCard and topCard.faceUp and topCard:containsPoint(x, y) then
      self.heldObject = topCard
      self.grabPos = Vector(x, y)
      topCard.state = CARD_STATE.GRABBED
      topCard.sourcePile = pile -- Track where it came from
      return
    end
  end
end



------------------------------------------------------------------------
--  Calls from love.mousereleased in main.lua
------------------------------------------------------------------------

function GrabberClass:endDrag(x, y, piles)
  if not self.heldObject then return end

  local card = self.heldObject
  local fromPile = card.sourcePile
  local targetPile = nil
  local closestDist = math.huge

  -- Find nearest pile
  for _, pile in ipairs(piles) do
    local dist = math.sqrt((pile.position.x - x)^2 + (pile.position.y - y)^2)
    if dist < closestDist then
      closestDist = dist
      targetPile = pile
    end
  end

  local success = false
  if targetPile and targetPile:canAcceptCard(card) then
    if fromPile then
      fromPile:removeCard(card) -- remove it
    end

    targetPile:addCard(card)
    success = true
  end

  if not success and fromPile then
    -- Snap back
    card.position.x = fromPile.position.x
    card.position.y = fromPile.position.y
  end

  -- Re-fan draw pile if needed
  if fromPile and fromPile.type == "draw" then
    fromPile:updateVisibleFan()
  end

  card.state = CARD_STATE.IDLE
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
