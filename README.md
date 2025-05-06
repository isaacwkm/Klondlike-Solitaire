# Klondlike Solitaire
 cmpm 121

Assets used:

https://moxica.itch.io/casino-playing-cards


Things I think I did well:

I created systems for cards, piles, and the grabber (the player). Each class had a clearly defined role, and I avoided putting their related logic into main.lua, aiming to keep it readable. I also think I did a good job managing the logic of the card properly updating its position and place in data, and properly removing itself from its original pile that it was held in, using a single chain of method calls. I believe I kept it simple enough to the point that an observer pattern wasn't needed and a complex solution wasn't overengineered.


Things I would do differently:

I initially underestimated how much data needed to flow between cards, piles, and the grabber. For example, sourcePile wasn’t tracked at first, which caused issues when moving cards. If I did this again, I’d design think about the data flow more and maybe map it out to get an idea of ownership and dependencies more clearly. Going to Zac's office hours helped a lot with this but before I went to him, I definitely overlooked dataflow from the card to its source/original pile.

I also have a lot of methods defined in main.lua, and I think that code could partly be moved to new classes, but I'm not entirely sure what names they would have and if they're necessary at this point.