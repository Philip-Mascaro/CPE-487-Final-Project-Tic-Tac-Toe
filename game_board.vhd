LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY game_board IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC;
		user_val  : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END game_board;

ARCHITECTURE Behavioral OF game_board IS
	CONSTANT size  : INTEGER := 80;
	--CONSTANT rad_A : INTEGER := 40;
	--CONSTANT rad_B : INTEGER := 80;
	CONSTANT half_width: INTEGER := 20;
	SIGNAL pixel_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL screen_center_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL screen_center_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current ball motion - initialized to +4 pixels/frame
	--SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := -"00000000100";
	
	--REFERENCE:  https://www.edaboard.com/threads/using-integer-arrays-in-vhdl.132696/
	type int_array is array(1 to 9) of integer;
	type log_vec_array is array(1 to 9) of STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL test_x : int_array;
    SIGNAL test_y : int_array;
    SIGNAL test_x2 : int_array;
    SIGNAL test_y2 : int_array;
    SIGNAL test_rad2 : int_array;
    SIGNAL compare_radA2 : integer;
    SIGNAL compare_radB2 : integer;
    SIGNAL test_minus: int_array;
    SIGNAL test_plus: int_array;
    SIGNAL test_minus2: int_array;
    SIGNAL test_plus2: int_array;
    SIGNAL width: integer;
    SIGNAL test_width2: integer;
    
    SIGNAL board_center_x  : log_vec_array;
    SIGNAL board_center_y  : log_vec_array;
    SIGNAL board_col: int_array;
    SIGNAL board_row: int_array;
    SIGNAL pixel_on_9: STD_LOGIC_VECTOR(1 TO 9);
    
    type state_type is (X, O, E); --X, O, and Empty
    type board_state is array(1 to 9) of state_type;
    SIGNAL board_status: board_state;
    
    
    SIGNAL try_pos: integer;
    SIGNAL try_state: state_type;
    
    SIGNAL attempt_test_x : integer;
    SIGNAL attempt_test_y : integer;
    SIGNAL attempt_test_x2 : integer;
    SIGNAL attempt_test_y2 : integer;
    SIGNAL attempt_test_rad2 : integer;
    SIGNAL attempt_compare_radA2 : integer;
    SIGNAL attempt_compare_radB2 : integer;
    SIGNAL attempt_test_minus: integer;
    SIGNAL attempt_test_plus: integer;
    SIGNAL attempt_test_minus2: integer;
    SIGNAL attempt_test_plus2: integer;
    SIGNAL attempt_width: integer;
    SIGNAL attempt_test_width2: integer;
    
    SIGNAL attempt_board_center_x  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL attempt_board_center_y  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL attempt_pixel_on: STD_LOGIC;
    
    SIGNAL valid_move: STD_LOGIC;
    

	
	
	
	
	
	
BEGIN
    try_pos <= conv_integer(user_val);




--	red <= NOT ball_on;--'1'; -- color setup for red ball on white background
--	green <= NOT ball_on;
--	blue  <= NOT ball_on;
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (pixel_row, pixel_col, board_status, valid_move) IS
	BEGIN
	
       width <= 2*half_width;--rad_B - rad_A;
       test_width2 <= width * width;
       compare_radA2 <= (size-width)*(size-width);--rad_A * rad_A;
       compare_radB2 <= size*size;--rad_B * rad_B;
       pixel_on <= '0';
       pixel_on_9 <= "000000000";
       
       
       board_col(1) <= -1;
       board_col(2) <= 0;
       board_col(3) <= 1;
       board_col(4) <= -1;
       board_col(5) <= 0;
       board_col(6) <= 1;
       board_col(7) <= -1;
       board_col(8) <= 0;
       board_col(9) <= 1;
       
       board_row(1) <= -1;
       board_row(2) <= -1;
       board_row(3) <= -1;
       board_row(4) <= 0;
       board_row(5) <= 0;
       board_row(6) <= 0;
       board_row(7) <= 1;
       board_row(8) <= 1;
       board_row(9) <= 1;
       
       
       
       
       
       
	   for index in 1 to 9 loop
            board_center_x(index) <= screen_center_x + board_col(index)*(size+size+15);
            board_center_y(index) <= screen_center_y + board_row(index)*(size+size+15);
       
            IF (pixel_col >= board_center_x(index) - size) AND
             (pixel_col <= board_center_x(index) + size) AND
                 (pixel_row >= board_center_y(index) - size) AND
                 (pixel_row <= board_center_y(index) + size) THEN
                 
                    test_x(index) <= conv_integer(pixel_col) - conv_integer(board_center_x(index));
                    test_y(index) <= conv_integer(pixel_row) - conv_integer(board_center_y(index));
                    test_minus(index) <= test_x(index) - test_y(index);
                    test_plus(index) <= test_x(index) + test_y(index);
                    test_minus2(index) <= test_minus(index) * test_minus(index);
                    test_plus2(index) <= test_plus(index) * test_plus(index);
                    test_x2(index) <= test_x(index) * test_x(index);
                    test_y2(index) <= test_y(index) * test_y(index);
                    test_rad2(index) <= test_x2(index) + test_y2(index);
                    
                    IF (board_status(index) = X) THEN
                        IF (2*test_minus2(index) <= test_width2 OR 2*test_plus2(index) <= test_width2) THEN
                            pixel_on_9(index) <= '1';
                        END IF;
                    ELSIF (board_status(index) = O) THEN
                        IF (test_rad2(index) >= compare_radA2 AND test_rad2(index) <= compare_radB2 ) THEN
                            pixel_on_9(index) <= '1';
                        END IF;
                    END IF;
--                ELSIF (pixel_col >= size+size+10+ball_x - size) AND
--                 (pixel_col <= size+size+10+ball_x + size) AND
--                     (pixel_row >= size+size+10+ball_y - size) AND
--                     (pixel_row <= size+size+10+ball_y + size) THEN
--                        test_x <= conv_integer(pixel_col) - conv_integer(size+size+10+ball_x);
--                        test_y <= conv_integer(pixel_row) - conv_integer(size+size+10+ball_y);
--                        test_x2 <= test_x * test_x;
--                        test_y2 <= test_y * test_y;
--                        test_rad2 <= test_x2 + test_y2;
--                        IF (test_rad2 >= compare_radA2 AND test_rad2 <= compare_radB2 ) THEN
--                            ball_on <= '1';
--                        END IF;
--                ELSIF (pixel_col >= ball_x-(size+size+10) - size) AND
--                 (pixel_col <= ball_x-(size+size+10) + size) AND
--                     (pixel_row >= ball_y-(size+size+10) - size) AND
--                     (pixel_row <= ball_y-(size+size+10) + size) THEN
--                        test_x <= conv_integer(pixel_col) - conv_integer(ball_x-(size+size+10));
--                        test_y <= conv_integer(pixel_row) - conv_integer(ball_y-(size+size+10));
--                        test_x2 <= test_x * test_x;
--                        test_y2 <= test_y * test_y;
--                        test_rad2 <= test_x2 + test_y2;
--                        IF (test_rad2 >= compare_radA2 AND test_rad2 <= compare_radB2 ) THEN
--                            ball_on <= '1';
--                        END IF;
    --		ELSE
    --			ball_on <= '0';
            END IF;
        end loop;
        IF (pixel_on_9 = "000000000") THEN pixel_on <= '0';
        ELSE pixel_on <= '1';
        END IF;
        
       attempt_test_width2 <= half_width * half_width;
       attempt_compare_radA2 <= (size-width+half_width/2)*(size-width+half_width/2);--rad_A * rad_A;
       attempt_compare_radB2 <= (size-half_width/2)*(size-half_width/2);--rad_B * rad_B;
       attempt_pixel_on <= '0';
       
       attempt_board_center_x <= screen_center_x + board_col(try_pos)*(size+size+15);
       attempt_board_center_y <= screen_center_y + board_row(try_pos)*(size+size+15);
        
        IF (pixel_col >= attempt_board_center_x - size) AND
        (pixel_col <= attempt_board_center_x + size) AND
            (pixel_row >= attempt_board_center_y - size) AND
            (pixel_row <= attempt_board_center_y + size) THEN
             
            attempt_test_x <= conv_integer(pixel_col) - conv_integer(attempt_board_center_x);
            attempt_test_y <= conv_integer(pixel_row) - conv_integer(attempt_board_center_y);
            attempt_test_minus <= attempt_test_x - attempt_test_y;
            attempt_test_plus <= attempt_test_x + attempt_test_y;
            attempt_test_minus2 <= attempt_test_minus * attempt_test_minus;
            attempt_test_plus2 <= attempt_test_plus * attempt_test_plus;
            attempt_test_x2 <= attempt_test_x * attempt_test_x;
            attempt_test_y2 <= attempt_test_y * attempt_test_y;
            attempt_test_rad2 <= attempt_test_x2 + attempt_test_y2;
            
            IF (try_state = X) THEN
                IF (2*attempt_test_minus2 <= attempt_test_width2 OR 2*attempt_test_plus2 <= attempt_test_width2) THEN
                    attempt_pixel_on <= '1';
                END IF;
            ELSIF (try_state = O) THEN
                IF (attempt_test_rad2 >= attempt_compare_radA2 AND attempt_test_rad2 <= attempt_compare_radB2 ) THEN
                    attempt_pixel_on <= '1';
                END IF;
            END IF;
        END IF;
        
        
    END PROCESS;
    
    b_status : PROCESS (board_status, try_pos, try_state) IS
	BEGIN
       board_status(1) <= O;
       board_status(2) <= X;
       board_status(3) <= E;
       board_status(4) <= O;
       board_status(5) <= E;
       board_status(6) <= X;
       board_status(7) <= E;
       board_status(8) <= O;
       board_status(9) <= X;
       
       --try_pos <= 5;
       try_state <= X;
    END PROCESS;
    
    b_attempt: PROCESS (board_status, try_pos, try_state, pixel_on, valid_move) IS
    BEGIN
        IF (attempt_pixel_on = '1') THEN
            IF board_status(try_pos) = E THEN
                valid_move <= '1';
            ELSE
                valid_move <= '0';
            END IF;
            
        END IF;
    END PROCESS;
    
    b_set_board: PROCESS (pixel_on, valid_move, attempt_pixel_on) IS
    BEGIN
        
        IF (attempt_pixel_on = '0') THEN
            IF (pixel_on = '0') THEN
                red <= '1';
                green <= '1';
                blue  <= '1';
            ELSE
                red <= '0';
                green <= '0';
                blue  <= '0';
            END IF;
        ELSE
            IF valid_move = '1' THEN
                red <= '0';
                green <= '1';
                blue  <= '0';
            ELSE
                red <= '1';
                green <= '0';
                blue  <= '0';
            END IF;
        END IF;
    END PROCESS;
        
        
        
        
END Behavioral;