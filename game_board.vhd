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
		user_val  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		key_press : IN STD_LOGIC;
		in_clock  : IN STD_LOGIC
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
	SIGNAL winner : state_type := E;
	SIGNAL game_won : STD_LOGIC := ‘0’;
	SIGNAL win_positions : STD_LOGIC_VECTOR(1 TO 9) := “000000000”;

	
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

    type state_type is (X, O, E, DRAW);
    type board_state is array(1 to 9) of state_type;
    SIGNAL board_status: board_state;
    
    type color_type is (PIX_BLACK, PIX_RED, PIX_GREEN, PIX_BLUE, PIX_YELLOW, PIX_PINK, PIX_CYAN, PIX_WHITE);
    SIGNAL mycolor : color_type;
    
    signal conv_user_val: integer;
    signal lock_try_pos: integer := 1;
    SIGNAL try_pos: integer := 1;
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
    
    SIGNAL blink_counter : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL player1_turn, player2_turn : BOOLEAN := TRUE;

	SIGNAL i_won : STD_LOGIC;	
BEGIN
    update_board_process: PROCESS (user_value, board_status, try_pos, try_state)
BEGIN
    IF user_value = "1101" THEN  -- press D key
        IF board_status(conv_integer(try_pos)) = E THEN  -- state not taken yet
            -- Confirm the move and update the board
            board_status(conv_integer(try_pos)) <= try_state;

            -- Switch player turns
            IF player1_turn THEN
                player1_turn <= FALSE;
                player2_turn <= TRUE;
            ELSE
                player1_turn <= TRUE;
                player2_turn <= FALSE;
            END IF;
        END IF;
    END IF;
END PROCESS update_board_process;
	




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
    
--    b_status_update : PROCESS(key_press, user_val, current_try_pos) IS
--    BEGIN
--        IF key_press = '1' THEN
--            current_try_pos <= conv_integer(user_val);
--        ELSE
--            try_pos <= current_try_pos;
--        END IF;
--    END PROCESS;
    
--    b_lock : PROCESS(current_try_pos, try_pos) IS
--    BEGIN
--        IF current_try_pos /= try_pos THEN
            
--        END IF;
--    END PROCESS;


--    b_update_test : PROCESS(key_press, conv_user_val) IS
--    BEGIN
--        IF key_press = '1' THEN
--            --try_pos <= 1
--            try_pos <= conv_user_val;
--        ELSE
--            try_pos <= 5;
--        END IF;
--    END PROCESS;
    
--    b_integer : PROCESS(user_val) IS
--    BEGIN
--        conv_user_val <= conv_integer(user_val);
--    END PROCESS;
    
--    b_update_test : PROCESS(conv_user_val) IS
--    BEGIN
--            try_pos <= conv_user_val;
--    END PROCESS;
    
--    b_integer : PROCESS(user_val, key_press, try_pos) IS
--    BEGIN
--        IF key_press = '1' THEN
--            conv_user_val <= conv_integer(user_val);
--        ELSE
--            conv_user_val <= try_pos;
--        END IF;
--    END PROCESS;
    
    b_integer : PROCESS(user_val) IS
    BEGIN
        conv_user_val <= conv_integer(user_val);
    END PROCESS;
    
    b_counter : PROCESS (blink_counter) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            blink_counter <= blink_counter + 1;
        END IF;
    END PROCESS;
    
    b_update_test : PROCESS(key_press, conv_user_val, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF key_press = '1' THEN
                --try_pos <= 1
                IF conv_user_val > 0 and conv_user_val < 10 THEN
                    try_pos <= conv_user_val;
                END IF;
--            ELSE
--                try_pos <= 5;
            END IF;
		END IF;
    END PROCESS;
    
    
    b_status : PROCESS (board_status, try_state, user_val) IS
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
                mycolor <= PIX_WHITE;
            ELSE
                mycolor <= PIX_BLACK;
            END IF;
        ELSE
            IF valid_move = '1' THEN
                IF blink_counter(25) = '1' THEN
                    mycolor <= PIX_BLUE;
                ELSE
                    IF (pixel_on = '0') THEN
                    mycolor <= PIX_WHITE;
                    ELSE
                        mycolor <= PIX_BLACK;
                    END IF;
                END IF;
            ELSE
                IF blink_counter(25) = '1' THEN
                    mycolor <= PIX_RED;
                ELSE
                    IF (pixel_on = '0') THEN
                    mycolor <= PIX_WHITE;
                    ELSE
                        mycolor <= PIX_BLACK;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
	--win check
	b_win_check: PROCESS (board_status, try_pos, try_state, pixel_on, valid_move) IS
    BEGIN
        IF (attempt_pixel_on = '1') THEN
            IF board_status(try_pos) = E THEN
                valid_move <= '1';
                -- Make the move
                board_status(try_pos) <= try_state;
                
                -- Check for winning conditions
   FOR i IN 1 TO 3 LOOP
        -- Check cols
        IF (board_status(i) = board_status(i + 3) AND board_status(i + 3) = board_status(i + 6) AND board_status(i) /= E) THEN
            winner <= board_status(i);
            win_positions(i) <= ‘1’;
            win_positions(i+3) <= ‘1’;
            win_positions(i+6) <= ‘1’;
            game_won <= ‘1’;
        END IF;

        -- Check rows
        IF (board_status(3*(i-1)+1) = board_status(3*(i-1)+2) AND board_status(3*(i-1)+2) = board_status(3*(i-1)+3) AND board_status(i) /= E) THEN
            winner <= board_status(i);
            win_positions(3*(i-1)+1) <= ‘1’;
            win_positions(3*(i-1)+2) <= ‘1’;
            win_positions(3*(i-1)+3) <= ‘1’;
            game_won <= ‘1’;
        END IF;
    END FOR;

    -- Check diagonals
    IF (board_status(1) = board_status(5) AND board_status(5) = board_status(9) AND board_status(1) /= E) THEN
        winner <= board_status(1);
            win_positions(1) <= ‘1’;
            win_positions(5) <= ‘1’;
            win_positions(9) <= ‘1’;
            game_won <= ‘1’;
    END IF;
    IF (board_status(3) = board_status(5) AND board_status(5) = board_status(7) AND board_status(3) /= E) THEN
        winner <= board_status(3);
            win_positions(3) <= ‘1’;
            win_positions(5) <= ‘1’;
            win_positions(7) <= ‘1’;
            game_won <= ‘1’;
    END IF;
            ELSE
                valid_move <= '0';
            END IF;
        END IF;
    END PROCESS;

	b_am_i_a_winner: PROCESS(win_positions, pixel_on_9) IS
BEGIN
	--pixel_on_9 states which of the 9 play positions this pixel might be a part of
	--win_positions states which positions are winners
	--check if this pixel’s position is one of the winners
	for index in 1 to 9 loop
		IF (pixel_on_9(index) = win_positions(index) AND pixel_on_9(index) = ‘1’) THEN
			i_won <= ‘1’;
		ELSE
			i_won <= ‘0’;
		END IF;
	end loop;
END PROCESS;

    --REFERENCE:  https://stackoverflow.com/questions/27864903/with-select-statement-with-multiple-conditions-vhdl
    WITH mycolor SELECT
        red <= '1' when PIX_RED | PIX_PINK | PIX_YELLOW | PIX_WHITE,
               '0' when others;
    WITH mycolor SELECT
        green <= '1' when PIX_GREEN | PIX_CYAN | PIX_YELLOW | PIX_WHITE,
                 '0' when others;
    WITH mycolor SELECT
        blue <= '1' when PIX_BLUE | PIX_CYAN | PIX_PINK | PIX_WHITE,
                '0' when others;
        
        
END Behavioral;
