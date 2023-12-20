# CPE-487-Final-Project-Tic-Tac-Toe
## 1. Description
  * The program will create a playable game of Tic-Tac-Toe that can be played in either a player versus player mode or a player versus computer mode.
  *  To play the game you will need a Nexys Board, a keypad, and a monitor to display the game.
     ![photo of keypad](/Images/keypad.jpg)
     
  * Our Tic-Tac-Toe board uses buttons 1-9 for each board cell. 1 is top left, 9 is bottom right. A red blinking letter indicates an occupied space, while a blue blinking letter shows an open space for the current player's turn. Pressing the D key confirms an open space move.
   
   ![photo of board](/Images/board.jpg)
 
  * Our board simplifies the game experience. Use BTNU for player vs computer, BTND for player vs player. X and O are randomly assigned; choose before the game to determine the starting player. Press BTNU or BTND to reset the Tic-Tac-Toe game.

Connections of the diferent files:

![Block Diagram for how the files work together](/Images/487_Block_Diagram.jpg)

Connections of the processes on the inside of game_board.vhd :

![Block Diagram for how the Processes work together](/Images/487_Block_Diagram_Processes.jpg)

* SYNC_PROC: controls the finite state machhine connected to resetting the game
* b_tie_board_update: updates a signal that stores which positions of the board have been played
* b_is_tied: checks if all positions of the board are filled in
* b_game_tie_sum: updates a signal based on if the game has a winner and if the board is full
* update_board_process: sets the player order upon reset; during the game will update the board based on valid cell selections (by player or computer) and switch which player is active
* bdraw: states if a pixel is on or not based on if the board cell is an X, an O, or Empty; repeats the process for the attempted move and states if it is an attempted pixel on; also sets a signal if the pixel is in the top left 50x50 of the screen
* b_set_board: states which color each pixel should be based on if the game is running, if there is a win or a tie, and if there is an attempted move being played at that spot (note that the top left 50x50 of the screen is set to the parity of the computer's next attempt)
* (color swapping): not a process, but updates the pixel coloration based on which color signal the pixel is (8 color options only)
* b_integer: converts user selection on keypad to an integer
* b_counter: updates a counter that controls the blinking of the attempted move and updates when the computer can lock in its move
* b_am_i_a_winner: checks if the current pixel is both one that is part of a symbol on the board (and which cell that symbol is in), and is also part of the winning set of cells
* b_update_test: sets the current attempted position if the user has selected a value 1-9 on the keypad
* b_attempt: states if the current move the player is trying to make is valid or not (controls the color of the blinking symbol)
* b_resetter: sets the signal in charge of resetting the game based on if the user pressed one of the two reset buttons
* b_COMPUTER_SELECT: states if the user decided to reset to play against another player or against the computer
* b_win_check: if the game is running, checks if there is a win on the board, and which cells constitute the win (there can be multiple simultaneous wins); resets all check signals to 0 when reset is selected
* b_flip_player: switches which symbol is currently being played
* Rand_num_gen: generates a pseudorandom number
* smart_Computer_Move: computer move selection logic; prioritizes blocking a player win or creating a computer win, then if that is not available prioritize center, then corner, then edge

Notes:
* There is another process called "b_is_finished" that was used during testing that updates a signal only used in a sensitivity list. We did not remove it to make sure we did not introduce any random glitches into the code.
* There are two other computer codes included in comments: "rand_Computer_Move" and "dumb_Computer_Move". The user can attempt to use these for different computer playstyles. Note that "rand_Computer_Move" is glitchy and would need to be modified.
* The process "smart_Computer_Move" contains commented code that uses for loops to make the selections for blocking or winning. Vivado did not react as expected to this code, which is why it was replaced with hard coding in all blocking or win conditions.

## 2. Modifications
 * Utilized Lab 3 as the base framework for the game.
 * Utilized the keypad.vhdl file from Lab 4 and placed the keypad module in the vga_top.
 * Randomizer Code with seed [random number logic ](https://en.wikipedia.org/wiki/Linear_congruential_generator)
 * For the computer turn-based moves we just started from general game logic. What are commonly used strategies when playing and how to react to winning situations when they arise? After considering these we wrote this sudo code. Once the syntax is solid we set the move location determined by the logic to a signal to be dealt with for move confirmation.
   * If the middle is open take it
   * If not go for the corners
   * If there are two letters in any section with a space (win check)
   * Move there (Block or win that section)
   * Elsif plays a random move
* Switched to the dumb computer after issues with the randomizer happening to fast
   * Randomizer still used for who plays first
* X and O pixel logic [desmos link for drawing X and O](https://www.desmos.com/calculator/irfxf6ciac)

## 3. Summary of Steps
### a. Create a new RTL project siren in Vivado Quick Start
* Create six new source files of file type VHDL called clk_wiz_0, clk_wiz_0_wiz, game_board, keypad, vga_sync, and vga_top
* Create a new constraint file of file type XDC called vga_top
* Choose Nexys A7-100T board for the project
* Click 'Finish'
* Click design sources and copy the VHDL code from clk_wiz_0.vhd, clk_wiz_0_wiz.vhd, game_board.vhd, keypad.vhd, vga_sync.vhd, and vga_top.vhd
* Click constraints and copy the code from vga_top.xdc
### b. Run synthesis
### c. Run implementation and open implemented design
### d. Generate bitstream, open hardware manager, and program device
* Click 'Generate Bitstream'
* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
* Click 'Program Device' then xc7a100t_0 to download siren.bit to the Nexys A7-100T board

### e. Hardware Setup
* Connect the keypad KYPD to the nexys board PMOD PORT JA with the tongs going into the top half. Then connect the vga cable to the board's VGA port and a VGA-compatible TV.

## 4. Conclusion
### Task Breakdown
* Philip Mascaro was in charge of the graphical display for the game as well as the ability for the player to select their move. He also performed error fixing for various processes of the gameboard such as the resetting and tie functions.
* Jett Tinik worked on adding in the ability for players to confirm their moves, the ability to switch between the two players, and the computer opponent.
* Jeffrey Tharakan created the win conditions and the ability for players to reset the game and choose whether they want to do a player versus player game or a player versus computer game.
### Timeline
* Week 1: create the graphical display, made a google doc to divide up the work and keep track of code
* Week 2: add in move selection and confirmation
  * Troubleshoot move selection and graphical displays
  * Add blinking and coloring to the letters
* Week 3: add in win conditions and the ability to reset the game 
* Week 4: Fix issues with tie condition and add in computer opponent for player versus computer mode
  * Find a working randomizer and hardcode our computer logic into the program
  * Add in the ability to choose whether you want to play as X or O
### Problems
* "Ghost Signals": slightly hidden player moves that were registering on the display, but only on some monitors. Was impacting the win conditions of the game because the hidden signals were interacting with the visible ones.
* Reset buttons needed to have the signals they were resetting into different processes to avoid driver issues
* Tie condition was having mutliple errors including having the "O" signals appearing white in the display when they should have been black
ntation with all components.
* All of the VHDL random number generators we found either only worked in testbench or gave errors in Vivado. Eventually, we ended up using a random number generator with our own seed number (487) and we could not use it for our computer.
*  Issues with delay in the Computer Mode. Computer will sometimes play multiple times in a turn. Player could sometimes play alone. It would also play a move even after losing causing a double win because it would move faster than the win signal.
*  Holding the reset button for a while could potentially result in both players getting the same symbol.
### Potential Future Actions
* One idea we had after finishing the project would be to slow down the speed of the randomizer's clock for how often the random seed gets updated. This could potentially help with the issue where both players get the same symbol if the reset button is held for too long.
