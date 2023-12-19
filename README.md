# CPE-487-Final-Project-Tic-Tac-Toe
## 1. Description
  * The program will create a playable game of Tic-Tac-Toe that can be played in either a player versus player mode or a player versus computer mode.
  *  To play the game you will need a Nexys Board, a keypad and a monitor to display the game.
     ![photo of keypad](/Images/keypad.jpg)
  * [Add Description for how to use buttons to]
  * ![photo of keypad](/Images/board.jpg)
  * [Add Description of Board and how to do the reset]
  * [Block Diagram for how the files work together]

## 2. Modifications
 * Utilized Lab 3 as the base framework for the game.
 * Utilized the keypad.vhdl file from Lab 4 and placed the keypad module in the vga_top.

## 3. Summary of Steps
* [desmos link for drawing X and O](https://www.desmos.com/calculator/irfxf6ciac)

## 4. Conclusion
* Philip Mascaro was in charge of the graphical display for the game as well as the ability for the player to select their move. He also performed error fixing for various processes of the gameboard such as the resetting and tie functions.
* Jett Tinik worked on the adding in the ability for players to conform their moves, the ability to switch between the two players, and the computer opponent.
* Jeffrey Tharakan created the win conditions and the ability for players to reset the game and choose whether they want to do a player versus player game or a player versus computer game.
### Timeline
* Week 1: create the graphical display
* Week 2: add in move selection and confirmation
* Week 3: add in win conditions and the ability to reset the game 
* Week 4: Fix issues with tie condition and add in computer opponent for player versus computer mode
### Problems
* "Ghost Signals" Slightly hidden signals were registering on the display.
* Tie condition was having mutliple errors icnluding having the "O" signals appearing white in the display when they should have been black
ntation with all components.
