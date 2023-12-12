# CPE-487-Final-Project-Tic-Tac-Toe

* Program the FPGA to display a "bouncing ball" on a 800x600 [Video Graphics Array](https://en.wikipedia.org/wiki/Video_Graphics_Array) (VGA) monitor (See Section 8 on VGA Port and Subsection 8.1 on VGA System Timing of the [Reference Manual]( https://reference.digilentinc.com/_media/reference/programmable-logic/nexys-a7/nexys-a7_rm.pdf))
  * The Digilent Nexys A7-100T board has a female [VGA connector](https://en.wikipedia.org/wiki/VGA_connector) that can be connected to a VGA monitor via a VGA cable or a [High-Definition Multimedia Interface](https://en.wikipedia.org/wiki/HDMI) (HDMI) monitor via a [VGA-to-HDMI converter](https://www.ventioncable.com/product/vga-to-hdmi-converter/) with a [micro-B USB](https://en.wikipedia.org/wiki/USB_hardware) power supply.
  * [VGA video](https://web.mit.edu/6.111/www/s2004/NEWKIT/vga.shtml) uses separate wires to transmit the three color component signals and vertical and horizontal synchronization signals.
  * [Horizontal blanking interval](https://en.wikipedia.org/wiki/Horizontal_blanking_interval) consists of front porch, sync pulse, and back porch.
  * [Color mixing](https://en.wikipedia.org/wiki/Color_mixing) of the red and green lights is yellow, the green and blue lights is cyan, and the blue and red lights is magenta. In the absence of light of any color, the result is black. If all three primary colors of light are mixed in equal proportions, the result is neutral (gray or white).

* 2019-11-03 pull request by Peter Ho with the 800x600@60Hz support for 100MHz clock
  * The Xilinx [Clocking Wizard](https://www.xilinx.com/products/intellectual-property/clocking_wizard.html)
  * [7 Series FPGAs Clocking Resources User Guide](https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf)
  * CLKOUT0_DIVIDE_F in Line 124 of clk_wiz_0_clk_wiz.vhd was updated from 25.3125 to 25.25 because it shall be a multiple of 0.125

* The **_vga_sync_** module uses a clock to drive horizontal and vertical counters h_cnt and v_cnt, respectively.
  * These counters are then used to generate the various timing signals.
  * The vertical and horizontal sync waveforms, vsync and hsync, will go directly to the VGA display with the column and row address, pixel_col and pixel_row, of the current [pixel](https://en.wikipedia.org/wiki/Pixel) being displayed.
  * This module also takes as input the current red, green, and blue video data and gates it with a signal called video_on.
  * This ensures that no video is sent to the display during the sync and blanking periods.
  * Note that red, green, and blue video are each represented as 1-bit (on-off) quantities.
  * This is sufficient resolution for our application.

* The **_ball_** module will be used to generate the red, green, and blue video that will paint the ball on to the VGA display at its current position.
  * This module maintains signals ball_x and ball_y that represent the current position of the ball on the screen.
  * These are initialized to (400, 300) to start the ball in the center of the screen.
  * The module also maintains a signal ball_y_motion that represents the number of pixels that the ball should move in one frame period.
  * This is initialized to +4 pixels/frame.
  * The module generates one-bit red, green, and blue video signals that are normally all set to 1.
  * This produces a white screen background.
  * When the signal ball_on is set, the green and blue signals go to 0 that makes those pixels red.
  * The module takes as input the current pixel row and column address that is generated by the vga_sync module.
  * Whenever the ball position is within 8 pixels of the current pixel address (in both x and y directions), the process bdraw sets the signal ball_on.
  * This paints a red ball around the current pixel address.
  * A second process mball (activated by the vsync signal) updates the ball position once every frame.
  * When the ball reaches the top of the screen, it changes the ball motion to -4 pixels per frame.
  * When it reaches the bottom of the screen it changes the ball motion to +4 pixels per frame.

* The **_vga_top_** module will connect the **_vga_sync_** and **_ball_** modules together and connect the appropriate signals to the board.

### 1. Create a new RTL project _vgaball_ in Vivado Quick Start

* Create five new source files of file type VHDL called **_clk_wiz_0_**, **_clk_wiz_0_clk_wiz_**, **_vga_sync_**, **_ball_**, and **_vga_top_**

* Create a new constraint file of file type XDC called **_vga_top_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

* Click design sources and copy the VHDL code from clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, vga_sync.vhd, ball.vhd, and vga_top.vhd

* Click constraints and copy the code from vga_top.xdc

### 2. Run synthesis

### 3. Run implementation and open implemented design

### 4. Generate bitstream, open hardware manager, and program device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download vga_top.bit to the Nexys A7 board

### 5. Edit code with the following modifications (this will be your Lab 3 Extension/Submission!)

* Change the size and color of the ball

* Change the square ball to a round ball

* Introduce a new signal ball_x_motion to allow the ball to move both horizontally and vertically
