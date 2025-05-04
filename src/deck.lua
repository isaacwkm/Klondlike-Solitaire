-- deck.lua
DeckClass = {}

local suits = { "clubs", "diamonds", "hearts", "spades" }
local ranks = { "02", "03", "04", "05", "06", "07", "08", "09", "10", "jack", "queen", "king", "ace" }

function DeckClass:new()
  local deck = {
    cards = {} -- array of {suit = "hearts", rank = "02"}
  }

  -- Build the full deck
  for _, suit in ipairs(suits) do
    for _, rank in ipairs(ranks) do
      table.insert(deck.cards, {suit = suit, rank = rank})
    end
  end

  return setmetatable(deck, { __index = DeckClass })
end

function DeckClass:shuffle()
  -- Fisher-Yates shuffle
  for i = #self.cards, 2, -1 do
    local j = love.math.random(1, i)
    self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
  end
end

function DeckClass:deal()
  if #self.cards == 0 then
    return nil
  end

  return table.remove(self.cards) -- pops from the end
end

function DeckClass:remaining()
  return #self.cards
end
