require "vector"

GrabberClass = {}

function GrabberClass:new()
  local g = {
    currentMousePos  = Vector(),
    previousMousePos = Vector(),
    heldObject       = nil,     -- Card or table of cards
    grabPos          = Vector()
  }
  return setmetatable(g, { __index = GrabberClass })
end

------------------------------------------------------------------------
-- update
------------------------------------------------------------------------
function GrabberClass:update(dt)
  local mx, my = love.mouse.getPosition()
  self.previousMousePos = self.currentMousePos
  self.currentMousePos = Vector(mx, my)

  if not self.heldObject then return end
  local offset = self.currentMousePos - self.previousMousePos

  for _, card in ipairs(self.heldObject) do
    card.position = card.position + offset
  end
end

------------------------------------------------------------------------
-- Called from love.mousepressed
------------------------------------------------------------------------
function GrabberClass:beginDrag(x, y, piles)
  for _, pile in ipairs(piles) do
    if pile.type == "tableau" then
      local stack = pile:getCardStackAt(x, y)
      if stack then
        self.heldObject = stack
        self.grabPos = Vector(x, y)

        for _, card in ipairs(stack) do
          card.originalPosition = Vector(card.position.x, card.position.y)
          card.sourcePile = pile
          card.state = CARD_STATE.GRABBED
        end
        return
      end
    else
      local topCard = pile.cards[#pile.cards]
      if topCard and topCard.faceUp and topCard:containsPoint(x, y) then
        self.heldObject = { topCard }
        self.grabPos = Vector(x, y)
        topCard.originalPosition = Vector(topCard.position.x, topCard.position.y)
        topCard.sourcePile = pile
        topCard.state = CARD_STATE.GRABBED
        return
      end
    end
  end
end

------------------------------------------------------------------------
-- Called from love.mousereleased
------------------------------------------------------------------------
function GrabberClass:endDrag(x, y, piles)
  if not self.heldObject then return end

  local stack = self.heldObject
  local topCard = stack[1]
  local fromPile = topCard.sourcePile
  local targetPile = nil
  local closestDist = math.huge

  -- Find nearest pile
  for _, pile in ipairs(piles) do
    local dist = math.sqrt((pile.position.x - x) ^ 2 + (pile.position.y - y) ^ 2)
    if dist < closestDist then
      closestDist = dist
      targetPile = pile
    end
  end

  local success = false

  -- Only allow multi-card stack moves onto tableau
  if targetPile and targetPile:canAcceptCard(topCard) then
    if #stack > 1 and targetPile.type ~= "tableau" then
      success = false
    else
      if fromPile then
        for _, card in ipairs(stack) do
          fromPile:removeCard(card)
        end
        fromPile:flipTopCardIfNeeded()
      end

      for _, card in ipairs(stack) do
        targetPile:addCard(card)
      end

      success = true
      checkWinCondition(piles)
    end
  end

  -- Snap back if invalid move
  if not success then
    for _, card in ipairs(stack) do
      if card.originalPosition then
        card.position = Vector(card.originalPosition.x, card.originalPosition.y)
        card.originalPosition = nil
      end
    end
  end

  -- Reset states
  for _, card in ipairs(stack) do
    card.state = CARD_STATE.IDLE
  end
  self.heldObject = nil

  -- Re-fan piles after move (important for draw pile layout)
  if fromPile and fromPile.type == "draw" then
    fromPile:updateVisibleFan()
  end
  if targetPile and targetPile.type == "draw" then
    targetPile:updateVisibleFan()
  end
end

