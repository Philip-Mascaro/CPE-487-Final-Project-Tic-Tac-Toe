# CPE-487-Final-Project-Tic-Tac-Toe
## 1. Description
  * The program will create a playable game of Tic-Tac-Toe that can be played in either a player versus player mode or a player versus computer mode.
  *  To play the game you will need a Nexys Board, a keypad and a monitor to display the game.
     ![photo of keypad](/Images/keypad.jpg)
     
  * Our Tic-Tac-Toe board uses buttons 1-9 for each quadrant. 1 is top left, 9 is bottom right. A red blinking letter indicates an occupied space, while a blue blinking letter shows an open space for the current player's turn. Pressing the D key confirms an open space move.
   
  * ![photo of board](/Images/board.jpg)
 
  * Our board simplifies the game experience. Use BTNU for player vs computer, BTND for player vs player. X and O are randomly assigned; choose before the game to determine the starting player. Press BTNU or BTND to reset the Tic-Tac-Toe game.

  * [Block Diagram for how the files work together]

## 2. Modifications
 * Utilized Lab 3 as the base framework for the game.
 * Utilized the keypad.vhdl file from Lab 4 and placed the keypad module in the vga_top.

## 3. Summary of Steps
*  Would this go here -> [desmos link for drawing X and O](https://www.desmos.com/calculator/irfxf6ciac)
* I Think this is more what he means,
* Connect the keypad to the nexys board [which port] with the tongs going into the top half. Then connect the vga cable to the board and the VGA-compatible TV.

### Create a new RTL project siren in Vivado Quick Start
* Create six new source files of file type VHDL called clk_wiz_0, clk_wiz_0_wiz, game_board, keypad, vga_sync, and vga_top
* Create a new constraint file of file type XDC called vga_top
* Choose Nexys A7-100T board for the project
* Click 'Finish'
* Click design sources and copy the VHDL code from clk_wiz_0.vhd, clk_wiz_0_wiz.vhd, game_board.vhd, keypad.vhd, vga_sync.vhd, and vga_top.vhd
* Click constraints and copy the code from vga_top.xdc
### Run synthesis
### Run implementation and open implemented design
### Generate bitstream, open hardware manager, and program device
* Click 'Generate Bitstream'
* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
* Click 'Program Device' then xc7a100t_0 to download siren.bit to the Nexys A7-100T board

## 5. Conclusion
### Task Breakdown
* Philip Mascaro was in charge of the graphical display for the game as well as the ability for the player to select their move. He also performed error fixing for various processes of the gameboard such as the resetting and tie functions.
* Jett Tinik worked on adding in the ability for players to conform their moves, the ability to switch between the two players, and the computer opponent.
* Jeffrey Tharakan created the win conditions and the ability for players to reset the game and choose whether they want to do a player versus player game or a player versus computer game.
### Timeline
* Week 1: create the graphical display
* Week 2: add in move selection and confirmation
* Week 3: add in win conditions and the ability to reset the game 
* Week 4: Fix issues with tie condition and add in computer opponent for player versus computer mode
### Problems
* "Ghost Signals" Slightly hidden player moves that were registering on the display, but only on some monitors. Was impacting the win conditions of the game because the hidden signals were interacting with the visible ones.
* Reset buttons needed to have the signals they were resetting into different processes to avoid driver issues
* Tie condition was having mutliple errors icnluding having the "O" signals appearing white in the display when they should have been black
ntation with all components.
