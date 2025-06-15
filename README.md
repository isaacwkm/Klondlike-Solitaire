# Klondlike Solitaire
 cmpm 121

Review on 5/5/25:

Review by: Jaren Kawai

Your code is very organized, and the overall readability of all your files is really good. The way you consistently formatted your code also helped me understand what everything was doing. I also like the use of the grabber class and a pile class to further encapsulate your code to prevent larger functions in other files. That is something that I personally wanted to do, but probably won’t be able to do before the deadline. 

A couple things that I noticed that are not major suggestions, but there is a lot of work being done in main. If possible, try to limit the amount of work being carried out in main.lua, and if functionality can be moved to other files that is a good habit to have. Additionally, try to avoid string comparisons between cards. If suit and rank are strings, it can be very easy to run into bugs related to something like spelling. I was doing this at first too since it was easy to both make a new card object and load in the card picture file with the same string. However, after also receiving feedback regarding implementing more enums, I think my code is better now.

Overall I think your code has been the most readable out of all the repositories I’ve had to review for this class, and although I think some of the functionality is missing, it won’t be difficult for you to add it without sacrificing readability. 


Review on 5/7/25:

Review by: Hunter

-code is clean and nicely decoupled

-readability is very compressed, but well organized and consistent

-only actual criticism is that the draw three could be decoupled, but Ionly just decoupled my draw 3 function and it made me want to blow my brains  out


Review on 5/7/25

Review by: Marcus Ochoa

Your code is clean and well commented. Logic is nicely compartmentalized so as to reduce repetitive code. One thing that stands out is the way card data is managed. Currently suits and ranks are stored as strings (deck.lua:4) and the card accesses its own sprite from a table with a combination of the two strings as a key (card.lua:35). Consider having the card class hold a reference to its sprite instead of having to perform a lookup, this is more intuitive since each card always has a sprite and removes a lookup operation. If you would rather keep sprites decoupled for flexibility, consider changing the sprite table to a nested table of ranks under suits and changing the rank and suit string values to integers or enums. This may require extra work in the front end assigning sprites without clear strings, but the data will be more robust and easier to work with especially once you implement placement validation. Another thing that stands out is the amount of game logic present in the main file. Particularly logic relating to the deck pile (main.lua:189) can perhaps be relocated to a deck pile class or another class handling deck logic that can reference the deck and draw piles (this is what I did). Another thing you can do in this regard is make a button class to handle the logic of clicking the deck (I also did this). A button class allows you to decouple some of the behavior and use that behavior for future buttons you might want such as a reset button.

Assets used:

https://moxica.itch.io/casino-playing-cards

##PROGRAMMING PATTERNS USED:

1. State Pattern
For card behavior (idle, grabbed, etc.), found in card.lua. Allows clean handling of drag-and-drop logic and decouples behavior from card structure.

2. Factory Pattern
For card creation and deck generation, in card.lua and deck.lua respectively. Centralizes the creation logic.

3. Flyweight Pattern
Used in deck.lua by sharing card back texture for all cards (if implemented via a manager or single instance). Slightly improves memory usage and performance.

4. Singleton Pattern
A single table a globally accessible variables in main.lua. Makes commonly used variables convenient to access.

5. Composite Pattern
A pile is made up of individual cards, but you can interact with the pile as one entity (check top card, draw group)



##Things I think I did well:

I created systems for cards, piles, and the grabber (the player). Each class had a clearly defined role, and I avoided putting their related logic into main.lua, aiming to keep it readable. I also think I did a good job managing the logic of the card properly updating its position and place in data, and properly removing itself from its original pile that it was held in, using a single chain of method calls. I believe I kept it simple enough to the point that an observer pattern wasn't needed and a complex solution wasn't overengineered.


##Things I would do differently:

I initially underestimated how much data needed to flow between cards, piles, and the grabber. For example, sourcePile wasn’t tracked at first, which caused issues when moving cards. If I did this again, I’d design think about the data flow more and maybe map it out to get an idea of ownership and dependencies more clearly. Going to Zac's office hours helped a lot with this but before I went to him, I definitely overlooked dataflow from the card to its source/original pile.

I also have a lot of methods defined in main.lua, and I think that code could partly be moved to new classes, but I'm not entirely sure what names they would have and if they're necessary at this point.

ALSO CONVERTING FILENAMES AND FACE CARD NAMES (JACK,QUEEN,KING) TO INTEGER-TYPES FOR LOGIC WAS SUCH A PAIN!!!
