-- pile.lua
require "vector"

PileClass = {}

function PileClass:new(x, y, type)
  local pile = {
    position = Vector(x, y),
    cards = {},
    type = type or "generic", -- tableau, foundation
    showOutline = true
  }
  return setmetatable(pile, { __index = PileClass })
end

------------------------------------------------------------
-- Add a card to the pile
------------------------------------------------------------
function PileClass:addCard(card)
  table.insert(self.cards, card)
  card.currentPile = self

  -- Update card's position relative to the pile
  local yOffset = (#self.cards - 1) * 20 -- 20 pixels vertical spacing
  card.position = self.position + Vector(0, yOffset)
end

------------------------------------------------------------
-- Remove a card from the pile
------------------------------------------------------------
function PileClass:removeCard(card)
  for i = #self.cards, 1, -1 do
    if self.cards[i] == card then
      table.remove(self.cards, i)
      return
    end
  end
end

------------------------------------------------------------
-- Flip top card
------------------------------------------------------------
function PileClass:flipTopCard()
  local top = self.cards[#self.cards]
  if top and not top.faceUp then
    top.faceUp = true
  end
end

------------------------------------------------------------
-- Draw all cards in the pile
------------------------------------------------------------
function PileClass:draw()
  -- draw dark blue outline slightly bigger than the card
  local outlinePadding = 4 -- 4 pixel bold thickness
  local outlineX = self.position.x - outlinePadding
  local outlineY = self.position.y - outlinePadding
  local outlineW = 80 + outlinePadding * 2
  local outlineH = 120 + outlinePadding * 2

  love.graphics.setColor(0.1, 0.1, 0.6, 1) -- dark blue
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", outlineX, outlineY, outlineW, outlineH, 8, 8)

  -- Draw pile type label centered above the pile
  local label = self.type or "pile"
  local font = love.graphics.getFont()
  local textWidth = font:getWidth(label)

  love.graphics.setColor(1, 1, 1, 0.6)
  love.graphics.print(
    label,
    self.position.x + 40 - textWidth / 2, -- center text
    self.position.y - 20 -- above pile
  )


  for _, card in ipairs(self.cards) do
    card:draw()
  end
end

------------------------------------------------------------
-- Find the topmost card under a given (x, y) point
------------------------------------------------------------
function PileClass:findTopCardAt(x, y)
  for i = #self.cards, 1, -1 do
    if self.cards[i]:containsPoint(x, y) then
      return self.cards[i]
    end
  end
  return nil
end
