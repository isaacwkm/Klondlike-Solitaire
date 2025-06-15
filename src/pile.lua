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
  -- Draw the outline
  local outlinePadding = 4
  local outlineX = self.position.x - outlinePadding
  local outlineY = self.position.y - outlinePadding
  local outlineW = 80 + outlinePadding * 2
  local outlineH = 120 + outlinePadding * 2

  love.graphics.setColor(0.1, 0.1, 0.6, 1)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", outlineX, outlineY, outlineW, outlineH, 8, 8)

  -- Draw label
  local label = self.type or "pile"
  local font = love.graphics.getFont()
  local textWidth = font:getWidth(label)

  love.graphics.setColor(1, 1, 1, 0.6)
  love.graphics.print(
    label,
    self.position.x + 40 - textWidth / 2,
    self.position.y - 20
  )

  -- Draw only top 3 cards for draw pile, all for other piles
  if self.type == "draw" then
    local count = #self.cards
    local firstVisible = math.max(count - 2, 1)

    for i = firstVisible, count do
      self.cards[i]:draw()
    end
  else
    for _, card in ipairs(self.cards) do
      card:draw()
    end
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

------------------------------------------------------------
-- Find the stack under a given (x, y) point
------------------------------------------------------------
function PileClass:getCardStackAt(x, y)
  for i = #self.cards, 1, -1 do
    local card = self.cards[i]
    if card.faceUp and card:containsPoint(x, y) then
      local stack = {}
      for j = i, #self.cards do
        table.insert(stack, self.cards[j])
      end
      return stack
    end
  end
  return nil
end

------------------------------------------------------------
-- update waste pile fanning downward
------------------------------------------------------------
function PileClass:updateVisibleFan()
  if self.type ~= "draw" then return end

  local count = #self.cards
  local firstVisible = math.max(count - 2, 1)

  for i = firstVisible, count do
    local card = self.cards[i]
    local yOffset = (i - firstVisible) * 20
    card.position.x = self.position.x
    card.position.y = self.position.y + yOffset
  end
end

------------------------------------------------------------
-- Valid movement validator
------------------------------------------------------------
function PileClass:canAcceptCard(card)
  if self.type == "tableau" then
    local topCard = self.cards[#self.cards]

    if not topCard then
      return card.rankValue == 13 -- Only Kings on empty tableau
    end

    return card:hasOppositeColor(topCard) and card.rankValue == topCard.rankValue - 1
  end

  if self.type == "foundation" then
    local topCard = self.cards[#self.cards]

    if not topCard then
      return card.rankValue == 1 -- Only Aces on empty foundation
    end

    return card.suit == topCard.suit and card.rankValue == topCard.rankValue + 1
  end

  return false
end

------------------------------------------------------------
-- Card flipping logic
------------------------------------------------------------

function PileClass:flipTopCardIfNeeded()
  if self.type == "tableau" then
    local top = self.cards[#self.cards]
    if top and not top.faceUp then
      top.faceUp = true
    end
  end
end
