-- card.lua
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE        = 0,
  HOVER       = 1,
  GRABBED     = 2
}

function CardClass:new(xPos, yPos, suit, rank)
  local card = {
    position = Vector(xPos, yPos),
    size     = Vector(50, 70),
    state    = CARD_STATE.IDLE,
    suit     = suit,
    rank     = rank,
    faceUp   = true,
    currentPile = nil
  }
  return setmetatable(card, { __index = CardClass })
end


------------------------------------------------------------
--  Per-frame update (animations tbd, nothing for now)
------------------------------------------------------------
function CardClass:update(dt) end

------------------------------------------------------------
--  Rendering
------------------------------------------------------------
function CardClass:draw(overrideX, overrideY)
  local key = self.suit .. "_" .. self.rank
  local img = game.cardSprites[key]

  if not self.faceUp then
    img = game.cardBack
  end

  if img then
    love.graphics.setColor(1, 1, 1, 1)

    -- Calculate scale factors
    local desiredWidth = 80
    local desiredHeight = 120

    local actualWidth = img:getWidth()
    local actualHeight = img:getHeight()

    local scaleX = desiredWidth / actualWidth
    local scaleY = desiredHeight / actualHeight

    -- Use override position if provided, else use self.position
    local x = overrideX or self.position.x
    local y = overrideY or self.position.y

    love.graphics.draw(img, x, y, 0, scaleX, scaleY)
  else
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y)
  end
end


------------------------------------------------------------
--  AABB test
------------------------------------------------------------
function CardClass:containsPoint(px, py)
  local img = game.cardSprites[self.suit .. "_" .. self.rank] or game.cardBack
  local scaleX = 80 / img:getWidth()
  local scaleY = 120 / img:getHeight()

  local width = img:getWidth() * scaleX
  local height = img:getHeight() * scaleY

  return
    px > self.position.x and
    px < self.position.x + width and
    py > self.position.y and
    py < self.position.y + height
end


------------------------------------------------------------
--  Called each frame from main.lua 
------------------------------------------------------------
function CardClass:updateHoverState(mouseX, mouseY, isDragging)
  if self.state == CARD_STATE.GRABBED then return end

  if self:containsPoint(mouseX, mouseY) and not isDragging then
    self.state = CARD_STATE.HOVER
  else
    self.state = CARD_STATE.IDLE
  end
end
