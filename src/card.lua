-- card.lua
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE    = 0,
  HOVER   = 1,
  GRABBED = 2
}

function CardClass:new(xPos, yPos, suit, rank)
  local map = {
    ["ace"] = 1,
    ["a"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["10"] = 10,
    ["jack"] = 11,
    ["j"] = 11,
    ["queen"] = 12,
    ["q"] = 12,
    ["king"] = 13,
    ["k"] = 13
  }

  local normalized = tostring(rank):lower():gsub("^0+", "")
  local value = map[normalized]

  if not value then
    error("Invalid rank: " .. tostring(rank))
  end

  local card = {
    position = Vector(xPos, yPos),
    rank = rank,       -- unchanged, "jack" or "10" or whatever
    rankValue = value, -- 11, 10, etc
    suit = suit,
    faceUp = true,
    currentPile = nil,
    originalPosition = nil,
    size = Vector(50, 70),
    state = CARD_STATE.IDLE
  }

  return setmetatable(card, { __index = CardClass })
end

------------------------------------------------------------
--  Color interpretation
------------------------------------------------------------

function CardClass:isRed()
  return self.suit == "hearts" or self.suit == "diamonds"
end

function CardClass:isBlack()
  return self.suit == "spades" or self.suit == "clubs"
end

function CardClass:hasOppositeColor(otherCard)
  return (self:isRed() and otherCard:isBlack()) or (self:isBlack() and otherCard:isRed())
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
