-- card.lua
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE        = 0,
  HOVER       = 1,
  GRABBED     = 2
}

function CardClass:new(xPos, yPos)
  local card = {
    position = Vector(xPos, yPos),
    size     = Vector(50, 70),
    state    = CARD_STATE.IDLE
  }
  return setmetatable(card, { __index = CardClass })
end

------------------------------------------------------------
--  Per-frame update (placeholder for flips / animations)
------------------------------------------------------------
function CardClass:update(dt) end

------------------------------------------------------------
--  Rendering
------------------------------------------------------------
function CardClass:draw()
  -- drop shadow if hovered or grabbed
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.6)
    local offset = (self.state == CARD_STATE.GRABBED) and 8 or 4
    love.graphics.rectangle("fill",
      self.position.x + offset,
      self.position.y + offset,
      self.size.x,
      self.size.y,
      6, 6)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("fill",
    self.position.x,
    self.position.y,
    self.size.x,
    self.size.y,
    6, 6)

  -- debug: show state
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print(self.state,
    self.position.x + 12,
    self.position.y + 26)
end

------------------------------------------------------------
--  Simple AABB hit-test used by GrabberClass
------------------------------------------------------------
function CardClass:containsPoint(px, py)
  return
    px > self.position.x and
    px < self.position.x + self.size.x and
    py > self.position.y and
    py < self.position.y + self.size.y
end

------------------------------------------------------------
--  Called each frame from main.lua after Grabber updates
------------------------------------------------------------
function CardClass:updateHoverState(mouseX, mouseY, isDragging)
  if self.state == CARD_STATE.GRABBED then return end

  if self:containsPoint(mouseX, mouseY) and not isDragging then
    self.state = CARD_STATE.HOVER
  else
    self.state = CARD_STATE.IDLE
  end
end
