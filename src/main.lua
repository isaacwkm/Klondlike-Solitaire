-- Isaac Kim
-- CMPM 121 – Pickup
-- 04-11-25
io.stdout:setvbuf("no")

require "card"
require "grabber"
require "pile"
require "deck"

-- ---------------------------------------------------------------------------
--  Singleton game table
-- ---------------------------------------------------------------------------
game = {
  grabber = nil,
  piles = {},
  snapPoints = {
    Vector(200, 200),
    Vector(300, 200),
    Vector(400, 200),
    Vector(500, 200),
  },
  cardSprites = {},
  stockPilePosition = Vector(10, 40),
  phase = "playing", -- "playing", "gameover"
}

local suits = { "clubs", "diamonds", "hearts", "spades" }
local ranks = { "02", "03", "04", "05", "06", "07", "08", "09", "10", "jack", "queen", "king", "ace" }

-- ---------------------------------------------------------------------------
--  utility
-- ---------------------------------------------------------------------------

function checkWinCondition(piles)
  local completeCount = 0

  for _, pile in ipairs(piles) do
    if pile.type == "foundation" and #pile.cards == 13 then
      completeCount = completeCount + 1
    end
  end

  if completeCount == 4 then
    game.phase = "gameover"
    print("YOU WIN!")
  end
end

function drawVictoryScreen()
  love.graphics.setColor(1, 1, 1, 1)

  local font = love.graphics.newFont(48)
  love.graphics.setFont(font)

  local message = "YOU WIN"
  local textWidth = font:getWidth(message)
  local textHeight = font:getHeight()

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  love.graphics.print(
    message,
    (screenWidth - textWidth) / 2,
    (screenHeight - textHeight) / 2
  )
end

-- Draw the stockpile cards left
local function drawStockPile()
  if not game.deck then return end

  -- Find the deck pile
  local x, y = 100, 100
  for _, pile in ipairs(game.piles) do
    if pile.type == "deck" then
      x = pile.position.x
      y = pile.position.y
      break
    end
  end

  local count = game.deck:remaining()
  local maxVisible = 24 -- at most in the stockpile drawn

  for i = 1, math.min(count, maxVisible) do
    local offset = (i - 1) * 0.5 -- slight offset each card

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
      game.cardBack,
      x,
      y + offset,
      0,
      80 / game.cardBack:getWidth(),
      120 / game.cardBack:getHeight()
    )
  end
end

-- ---------------------------------------------------------------------------
--  LOVE callbacks
-- ---------------------------------------------------------------------------
function love.load()
  love.window.setMode(1440, 720)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

  -- Initialize components
  game.grabber = GrabberClass:new()
  game.deck = DeckClass:new()
  game.deck:shuffle()

  -- Load card sprites
  for _, suit in ipairs(suits) do
    for _, rank in ipairs(ranks) do
      local key = suit .. "_" .. rank
      if not game.cardSprites[key] then
        local path = "cards/" .. key .. ".png"
        game.cardSprites[key] = love.graphics.newImage(path)
      end
    end
  end

  game.cardBack = love.graphics.newImage("cards/back01.png")

  -- Piles
  game.piles = {}
  local spacing = 100

  -- 7 Tableau
  local tableauStartX = 150
  for i = 1, 7 do
    local x = tableauStartX + (i - 1) * spacing
    table.insert(game.piles, PileClass:new(x, 400, "tableau"))
  end

  -- 4 Foundation
  local foundationStartX = 900
  for i = 1, 4 do
    local x = foundationStartX + (i - 1) * spacing
    table.insert(game.piles, PileClass:new(x, 50, "foundation"))
  end

  -- Deal 1–7 cards into the 7 tableau piles
  local tableauIndex = 1

  for i = 1, 7 do
    local pile = game.piles[tableauIndex]

    for j = 1, i do
      local cardData = game.deck:deal()
      if cardData then
        local card = CardClass:new(pile.position.x, pile.position.y + (j - 1) * 20, cardData.suit, cardData.rank)
        card.faceUp = (j == i) -- Only the last card in the pile is face up
        pile:addCard(card)
      end
    end

    tableauIndex = tableauIndex + 1
  end


  -- 1 Deck
  table.insert(game.piles, PileClass:new(100, 100, "deck"))

  -- 1 Draw
  table.insert(game.piles, PileClass:new(200, 100, "draw"))
end

function love.update(dt)
  -- Update grabber first
  game.grabber:update(dt)

  -- Update all cards in all piles
  local mx, my   = game.grabber.currentMousePos.x, game.grabber.currentMousePos.y
  local dragging = (game.grabber.heldObject ~= nil)

  for _, pile in ipairs(game.piles) do
    for _, card in ipairs(pile.cards) do
      card:update(dt)
      card:updateHoverState(mx, my, dragging)
    end
  end
end

function love.draw()
  for _, pile in ipairs(game.piles) do
    pile:draw()
  end

  drawStockPile()

  love.graphics.setColor(1, 1, 1, 1)
  local mx, my = game.grabber.currentMousePos.x, game.grabber.currentMousePos.y
  love.graphics.print(("Mouse: %.0f, %.0f"):format(mx, my), 10, 10)

  if game.phase == "gameover" then
    drawVictoryScreen()
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    -- Check for click on deck pile
    for _, pile in ipairs(game.piles) do
      if pile.type == "deck" and pointInRect(x, y, pile.position.x, pile.position.y, 80, 120) then
        drawThreeToDrawPile()
        return
      end
    end

    -- Otherwise, try to grab a card
    game.grabber:beginDrag(x, y, game.piles)
  end
end

function love.mousereleased(x, y, button)
  if button == 1 then
    game.grabber:endDrag(x, y, game.piles)
  end
end

function pointInRect(px, py, x, y, w, h)
  return px >= x and px <= x + w and py >= y and py <= y + h
end

function drawThreeToDrawPile()
  local drawPile = nil
  for _, pile in ipairs(game.piles) do
    if pile.type == "draw" then
      drawPile = pile
      break
    end
  end
  if not drawPile then return end

  -- Check if deck is empty
  if game.deck:isEmpty() then
    reshuffleDrawPileIntoDeck(drawPile)
  end

  -- Draw up to 3 cards
  for i = 1, 3 do
    local cardData = game.deck:deal()
    if cardData then
      local card = CardClass:new(0, 0, cardData.suit, cardData.rank)
      card.faceUp = true
      card.sourcePile = drawPile
      drawPile:addCard(card)
    end
  end

  drawPile:updateVisibleFan()
end

function reshuffleDrawPileIntoDeck(drawPile)
  -- Pull cards from draw pile back into the deck
  for i = #drawPile.cards, 1, -1 do
    local card = drawPile.cards[i]
    table.remove(drawPile.cards, i)

    card.faceUp = false
    game.deck:insertTop({suit = card.suit, rank = card.rank})
  end
end
