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
		in_clock  : IN STD_LOGIC;
        reset_pvp : IN STD_LOGIC;
        reset_pve : IN STD_LOGIC
	);
END game_board;

ARCHITECTURE Behavioral OF game_board IS
	CONSTANT size  : INTEGER := 80;
	CONSTANT half_width: INTEGER := 20;
	SIGNAL pixel_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	-- current ball position - intitialized to center of screen
	SIGNAL screen_center_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL screen_center_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	
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
    SIGNAL board_col: int_array := (-1,0,1,-1,0,1,-1,0,1);
    SIGNAL board_row: int_array := (-1,-1,-1,0,0,0,1,1,1);
    SIGNAL pixel_on_9: STD_LOGIC_VECTOR(1 TO 9);
    
    type state_type is (O, X, E); --X, O, and Empty
    type board_state is array(1 to 9) of state_type;
    SIGNAL board_status: board_state := (E,E,E,E,E,E,E,E,E);--(O,X,E,O,E,X,E,O,X);
    
    type color_type is (PIX_BLACK, PIX_RED, PIX_GREEN, PIX_BLUE, PIX_YELLOW, PIX_PINK, PIX_CYAN, PIX_WHITE);
    SIGNAL mycolor : color_type;
    
    signal conv_user_val: integer;
    SIGNAL try_pos: integer := 5;
    SIGNAL try_state: state_type;
    SIGNAL swap_count: integer := 0;
    SIGNAL swap_vector: std_logic_vector(1 downto 0);
    
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
    SIGNAL attempt_test_width2: integer;
    
    SIGNAL attempt_board_center_x  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL attempt_board_center_y  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL attempt_pixel_on: STD_LOGIC;
    
    SIGNAL valid_move: STD_LOGIC;
    
    SIGNAL blink_counter : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL i_won : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL winner : state_type;
	SIGNAL game_won : INTEGER := 0;
	SIGNAL win_positions_row : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL win_positions_col : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL win_positions_diag1 : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL win_positions_diag2 : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL win_positions : STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL pos_played :  STD_LOGIC_VECTOR(1 TO 9) := "000000000";
	SIGNAL is_tied : INTEGER := 0;
    SIGNAL game_finished : INTEGER := 0;
	SIGNAL game_tie_sum : INTEGER := 0;
	
	SIGNAL player1_turn : BOOLEAN := TRUE;
	SIGNAL reset_game : STD_LOGIC;
	SIGNAL Player1_value : state_type;
    SIGNAL Player2_value : state_type;
    SIGNAL Computer_value : state_type;
    SIGNAL Comp_opp : STD_LOGIC;

    SIGNAL button_visual : std_logic;
	type signal_resetting is (ST0, ST1);
	SIGNAL PS, NS: signal_resetting;
	
	
	
    SIGNAL ai_pos: INTEGER;
    SIGNAL my_seed: INTEGER := 487;
    
    SIGNAL rand_a: INTEGER := 75;
    SIGNAL rand_c: INTEGER := 74;
    SIGNAL rand_m: INTEGER := 65537;
	
BEGIN

    --ALWAYS RUNNING
    
    SYNC_PROC: process(reset_game, NS, in_clock) IS
    BEGIN
        IF reset_game = '1' THEN
            PS <= ST0;
        ELSIF rising_edge(in_clock) THEN
            PS <= NS;
        END IF;
    END PROCESS;
    
    b_tie_board_update : process(board_status, pos_played, in_clock) IS
    BEGIN
        IF PS = ST0 THEN
            pos_played <= "000000000";
        ELSE
            IF rising_edge(in_clock) THEN
                for index in 1 to 9 loop
                    if (board_status(index) /= E) then
                        pos_played(index) <= '1';
                    end if;
                end loop;
            end if;
        end if;
    END PROCESS;
    
    b_is_tied : process (in_clock, pos_played) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            if pos_played = "111111111" then
                is_tied <= 1;
            else
                is_tied <= 0;
            end if;
        end if;
    END PROCESS;
    
    b_game_tie_sum : process(in_clock, game_won, is_tied) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            game_tie_sum <= game_won + is_tied;
        end if;
    END PROCESS;
    
    b_is_finished: process(in_clock, game_won) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            if (game_won > 0) then
                game_finished <= 1;
            else
                game_finished <= 0;
            end if;
        end if;
    END PROCESS;
    
    update_board_process: PROCESS (user_val, board_status, try_pos, try_state, in_clock, key_press, swap_count, swap_vector, PS, ai_pos, Computer_value, Comp_opp, game_tie_sum, blink_counter, my_seed)
    variable my_rand: integer;
    BEGIN
        IF PS = ST0 THEN
            --FIXED
    
            Board_status <= (E,E,E,E,E,E,E,E,E);
    
    
            --RANDOMIZED
            my_rand := my_seed mod 4;
            if my_rand = 0 THEN
                Player1_value <= X;
                Player2_value <= O;
                Computer_value <= O;
            elsif  my_rand = 1 THEN
                Player1_value <= O;
                Player2_value <= X;
                Computer_value <= O;
            elsif  my_rand = 2 THEN
                Player1_value <= O;
                Player2_value <= X;
                Computer_value <= X;
            else
                Player1_value <= X;
                Player2_value <= O;
                Computer_value <= X;
            end if;
    
            NS <= ST1;
        ELSE
           IF rising_edge(in_clock) THEN
                IF ( (try_state = Computer_value) and (Comp_opp = '1') and (game_tie_sum = 0)) THEN
                    IF (blink_counter(25)= '1') THEN
                        if board_status(ai_pos) = E then
                            board_status(ai_pos) <= try_state;
                        
                            IF player1_turn THEN
                                player1_turn <= FALSE;
                            ELSE
                                player1_turn <= TRUE;
                            END IF;
                        END IF;
                        
                    END IF;
                else
                    IF key_press = '1' THEN
                        IF user_val = "1101" AND game_won = 0 THEN  -- press D key
                            IF board_status(try_pos) = E THEN  -- state not taken yet
                                -- Confirm the move and update the board
                                board_status(try_pos) <= try_state;
                    
                                -- Switch player turns
                                IF player1_turn THEN
                                    player1_turn <= FALSE;
                                ELSE
                                    player1_turn <= TRUE;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
           END IF;
        END IF;
    END PROCESS update_board_process;
    
    
	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (pixel_row, pixel_col, board_status, valid_move, in_clock, button_visual) IS
	BEGIN
        
        IF (pixel_row < 50 AND pixel_col < 50) THEN
            button_visual <= '1';
        else
            button_visual <= '0';
        end if;
        
       width <= 2*half_width;--rad_B - rad_A;
       test_width2 <= width * width;
       compare_radA2 <= (size-width)*(size-width);--rad_A * rad_A;
       compare_radB2 <= size*size;--rad_B * rad_B;
       pixel_on <= '0';
       pixel_on_9 <= "000000000";

       
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
            END IF;
        end loop;
        
        IF (pixel_on_9 = "000000000") THEN
            pixel_on <= '0';
        ELSE
            pixel_on <= '1';
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
    
    
    b_set_board: PROCESS (pixel_on, valid_move, attempt_pixel_on, game_won, i_won, in_clock, reset_pvp, reset_pve, pos_played, is_tied, game_finished, GAME_TIE_SUM, ai_pos) IS
    BEGIN
        IF (button_visual = '1') THEN

            IF ((ai_pos mod 2) = 1) then --is_tied
                mycolor <= PIX_BLACK;
            ELSE
                mycolor <= PIX_YELLOW;
            END IF;

        ELSE
            IF (game_tie_sum = 0) THEN --game_won = 0 and 
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
            ELSE
                IF (pixel_on = '0') THEN
                    mycolor <= PIX_WHITE;
                ELSE
                    IF (game_won = 1) THEN
                        IF (i_won /= "000000000") THEN
                            mycolor <= PIX_GREEN;
                        ELSE
                            IF (pixel_on = '0') THEN
                                mycolor <= PIX_WHITE;
                            ELSE
                                mycolor <= PIX_BLACK;
                            END IF;
                        END IF;
                        
                    ELSE
                        IF (pixel_on = '0') THEN
                            mycolor <= PIX_WHITE;
                        ELSE
                            mycolor <= PIX_YELLOW;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        
        
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
        
    
    
    b_integer : PROCESS(user_val, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            conv_user_val <= conv_integer(user_val);
        END IF;
    END PROCESS;
    
    
    b_counter : PROCESS (blink_counter, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            blink_counter <= blink_counter + 1;
        END IF;
    END PROCESS;

	b_am_i_a_winner: PROCESS(win_positions, pixel_on_9, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            i_won <= pixel_on_9 AND win_positions; -- if i_won is all 0, either black or white, otherwise green
        END IF;
    END PROCESS;
    
    
    b_update_test : PROCESS(key_press, conv_user_val, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF key_press = '1' THEN
                IF conv_user_val > 0 and conv_user_val < 10 THEN
                    try_pos <= conv_user_val;
                END IF;
            END IF;
		END IF;
    END PROCESS;
    
    
    b_attempt: PROCESS (board_status, try_pos, try_state, pixel_on, valid_move, in_clock) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF (attempt_pixel_on = '1') THEN
                IF board_status(try_pos) = E THEN
                    valid_move <= '1';
                ELSE
                    valid_move <= '0';
                END IF;
                
            END IF;
        END IF;
    END PROCESS;
    
    b_resetter: PROCESS(in_clock, reset_pvp, reset_pve) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF reset_pvp = '1' OR reset_pve = '1' THEN
                reset_game <= '1';
            ELSE
                reset_game <= '0';
            END IF;
        END IF;
    END PROCESS;
    
    
    --BUTTON PRESSED
    
    b_COMPUTER_SELECT: PROCESS (in_clock, reset_pvp, reset_pve) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF ( NOT(reset_pvp = '1' AND reset_pve = '1' )) THEN
                IF reset_pvp = '1' THEN
                    Comp_opp <= '0';
                END IF;
                IF reset_pve = '1' THEN
                    Comp_opp <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    --win check
	b_win_check: PROCESS (board_status, try_pos, try_state, pixel_on, valid_move, blink_counter, in_clock, PS) IS
    BEGIN
        IF (PS = ST1) THEN
            IF rising_edge(in_clock) THEN    
                -- Check for winning conditions
                FOR i IN 1 TO 3 LOOP
                    -- Check cols
                    IF (board_status(i) = board_status(i + 3) AND board_status(i + 3) = board_status(i + 6) AND board_status(i) /= E) THEN
                        winner <= board_status(i);
                        win_positions_col(i) <= '1';
                        win_positions_col(i+3) <= '1';
                        win_positions_col(i+6) <= '1';
                    END IF;
                
                    -- Check rows
                    IF (board_status(3*(i-1)+1) = board_status(3*(i-1)+2) AND board_status(3*(i-1)+2) = board_status(3*(i-1)+3) AND board_status(3*(i-1)+1) /= E) THEN
                        winner <= board_status(i);
                        win_positions_row(3*(i-1)+1) <= '1';
                        win_positions_row(3*(i-1)+2) <= '1';
                        win_positions_row(3*(i-1)+3) <= '1';
                    END IF;
                END loop;
            
            -- Check diagonals
                IF (board_status(1) = board_status(5) AND board_status(5) = board_status(9) AND board_status(1) /= E) THEN
                    winner <= board_status(5);
                    win_positions_diag1(1) <= '1';
                    win_positions_diag1(5) <= '1';
                    win_positions_diag1(9) <= '1';
                END IF;
            
                IF (board_status(3) = board_status(5) AND board_status(5) = board_status(7) AND board_status(3) /= E) THEN
                    winner <= board_status(5);
                    win_positions_diag2(3) <= '1';
                    win_positions_diag2(5) <= '1';
                    win_positions_diag2(7) <= '1';
                END IF;
            
                win_positions <= (win_positions_col or win_positions_row) or (win_positions_diag1 or win_positions_diag2);
                IF (win_positions /= "000000000") THEN
                    game_won <= 1;
                END IF;
            END IF;
        ELSE
            game_won <= 0;
            winner <= E;
            win_positions_row <= "000000000";
            win_positions_col <= "000000000";
            win_positions_diag1 <= "000000000";
            win_positions_diag2 <= "000000000";
            win_positions <= "000000000";
        END IF;
    END PROCESS;
    
    b_flip_player: PROCESS (in_clock, player1_turn, Player1_value, Player2_value) IS
    BEGIN
        IF rising_edge(in_clock) THEN
            IF player1_turn THEN
                try_state <= Player1_value;
            ELSE
                try_state <= Player2_value;
            END IF;
        END IF;
    END PROCESS;


--REFERENCE:  https://en.wikipedia.org/wiki/Linear_congruential_generator
    Rand_num_gen: process(in_clock, rand_a, rand_c, rand_m, my_seed) IS
    begin
        IF rising_edge(in_clock) THEN
            my_seed <= (rand_a*my_seed+rand_c) mod rand_m;
        end if;
    end process;

    -- Declare a process for computer move
        


--    dumb_Computer_Move: PROCESS (board_status, blink_counter) IS
--    begin
--        IF (blink_counter(25)= '0') THEN
--            if board_status(1) = E THEN
--                ai_pos <= 1;
--            elsif board_status(2) = E THEN
--                ai_pos <= 2;
--            elsif board_status(3) = E THEN
--                ai_pos <= 3;
--            elsif board_status(4) = E THEN
--                ai_pos <= 4;
--            elsif board_status(5) = E THEN
--                ai_pos <= 5;
--            elsif board_status(6) = E THEN
--                ai_pos <= 6;
--            elsif board_status(7) = E THEN
--                ai_pos <= 7;
--            elsif board_status(8) = E THEN
--                ai_pos <= 8;
--            elsif board_status(9) = E THEN
--                ai_pos <= 9;
--            end if;
--        end if;
--    end process;
    
    smart_Computer_Move: PROCESS (board_status, blink_counter) IS
    begin
        IF (blink_counter(25)= '0') THEN
               IF (board_status(1) = board_status(2) AND board_status(1) /= E AND board_status(3) = E) THEN ai_pos <= 3;
            ELSIF (board_status(1) = board_status(3) AND board_status(1) /= E AND board_status(2) = E) THEN ai_pos <= 2;
            ELSIF (board_status(2) = board_status(3) AND board_status(2) /= E AND board_status(1) = E) THEN ai_pos <= 1;
            
            ELSIF (board_status(4) = board_status(5) AND board_status(4) /= E AND board_status(6) = E) THEN ai_pos <= 6;
            ELSIF (board_status(4) = board_status(6) AND board_status(4) /= E AND board_status(5) = E) THEN ai_pos <= 5;
            ELSIF (board_status(5) = board_status(6) AND board_status(5) /= E AND board_status(4) = E) THEN ai_pos <= 4;
            
            ELSIF (board_status(7) = board_status(8) AND board_status(7) /= E AND board_status(9) = E) THEN ai_pos <= 9;
            ELSIF (board_status(7) = board_status(9) AND board_status(7) /= E AND board_status(8) = E) THEN ai_pos <= 8;
            ELSIF (board_status(8) = board_status(9) AND board_status(8) /= E AND board_status(7) = E) THEN ai_pos <= 7;
            
            
            ELSIF (board_status(1) = board_status(4) AND board_status(1) /= E AND board_status(7) = E) THEN ai_pos <= 7;
            ELSIF (board_status(1) = board_status(7) AND board_status(1) /= E AND board_status(4) = E) THEN ai_pos <= 4;
            ELSIF (board_status(4) = board_status(7) AND board_status(4) /= E AND board_status(1) = E) THEN ai_pos <= 1;
            
            ELSIF (board_status(2) = board_status(5) AND board_status(2) /= E AND board_status(8) = E) THEN ai_pos <= 8;
            ELSIF (board_status(2) = board_status(8) AND board_status(2) /= E AND board_status(5) = E) THEN ai_pos <= 5;
            ELSIF (board_status(5) = board_status(8) AND board_status(5) /= E AND board_status(2) = E) THEN ai_pos <= 2;
            
            ELSIF (board_status(3) = board_status(6) AND board_status(3) /= E AND board_status(9) = E) THEN ai_pos <= 9;
            ELSIF (board_status(3) = board_status(9) AND board_status(3) /= E AND board_status(6) = E) THEN ai_pos <= 6;
            ELSIF (board_status(6) = board_status(9) AND board_status(6) /= E AND board_status(3) = E) THEN ai_pos <= 3;
            
            
            ELSIF (board_status(1) = board_status(5) AND board_status(1) /= E AND board_status(9) = E) THEN ai_pos <= 9;
            ELSIF (board_status(1) = board_status(9) AND board_status(1) /= E AND board_status(5) = E) THEN ai_pos <= 5;
            ELSIF (board_status(5) = board_status(9) AND board_status(5) /= E AND board_status(1) = E) THEN ai_pos <= 1;
            
            ELSIF (board_status(3) = board_status(5) AND board_status(3) /= E AND board_status(7) = E) THEN ai_pos <= 7;
            ELSIF (board_status(3) = board_status(7) AND board_status(3) /= E AND board_status(5) = E) THEN ai_pos <= 5;
            ELSIF (board_status(5) = board_status(7) AND board_status(5) /= E AND board_status(1) = E) THEN ai_pos <= 3;
--           IF (board_status(1) = board_status(2) AND board_status(1) /= E) OR
--           (board_status(2) = board_status(3) AND board_status(2) /= E) OR
--           (board_status(1) = board_status(3) AND board_status(1) /= E) THEN
--           -- Win or defend
--               IF board_status(1) = E THEN
--                    ai_pos <= 1;
--               ELSIF board_status(2) = E THEN
--                    ai_pos <= 2;
--               ELSE
--                    ai_pos <= 3;
--               END IF;
--            ELSIF (board_status(4) = board_status(5) AND board_status(4) /= E) OR
--               (board_status(5) = board_status(6) AND board_status(5) /= E) OR
--               (board_status(4) = board_status(6) AND board_status(4) /= E) THEN
--                -- Win or defend
--                IF board_status(4) = E THEN
--                    ai_pos <= 4;
--                ELSIF board_status(5) = E THEN
--                    ai_pos <= 5;
--                ELSE
--                    ai_pos <= 6;
--                END IF;
--             ELSIF (board_status(7) = board_status(8) AND board_status(7) /= E) OR
--               (board_status(8) = board_status(9) AND board_status(8) /= E) OR
--               (board_status(7) = board_status(9) AND board_status(7) /= E) THEN
--                -- Win or defend
--                IF board_status(7) = E THEN
--                    ai_pos <= 7;
--                ELSIF board_status(8) = E THEN
--                    ai_pos <= 8;
--                ELSE
--                    ai_pos <= 9;
--                END IF;
--            ELSIF (board_status(1) = board_status(4) AND board_status(1) /= E) OR
--               (board_status(4) = board_status(7) AND board_status(4) /= E) OR
--               (board_status(1) = board_status(7) AND board_status(1) /= E) THEN
--                -- Win or defend
--                IF board_status(1) = E THEN
--                    ai_pos <= 1;
--                ELSIF board_status(4) = E THEN
--                    ai_pos <= 4;
--                ELSE
--                    ai_pos <= 7;
--                END IF;
--            ELSIF (board_status(2) = board_status(5) AND board_status(2) /= E) OR
--               (board_status(5) = board_status(8) AND board_status(5) /= E) OR
--               (board_status(2) = board_status(8) AND board_status(2) /= E) THEN
--                -- Win or defend
--                IF board_status(2) = E THEN
--                    ai_pos <= 2;
--                ELSIF board_status(5) = E THEN
--                    ai_pos <= 5;
--                ELSE
--                    ai_pos <= 8;
--                END IF;
--            ELSIF (board_status(3) = board_status(6) AND board_status(3) /= E) OR
--               (board_status(6) = board_status(9) AND board_status(6) /= E) OR
--               (board_status(3) = board_status(9) AND board_status(3) /= E) THEN
--                -- Win or defend
--                IF board_status(3) = E THEN
--                    ai_pos <= 3;
--                ELSIF board_status(6) = E THEN
--                    ai_pos <= 6;
--                ELSE
--                    ai_pos <= 9;
--                END IF;
--            ELSIF (board_status(1) = board_status(5) AND board_status(1) /= E) OR
--               (board_status(5) = board_status(9) AND board_status(5) /= E) OR
--               (board_status(1) = board_status(9) AND board_status(1) /= E) THEN
--                -- Win or defend
--                IF board_status(1) = E THEN
--                    ai_pos <= 1;
--                ELSIF board_status(5) = E THEN
--                    ai_pos <= 5;
--                ELSE
--                    ai_pos <= 9;
--                END IF;
--            ELSIF (board_status(3) = board_status(5) AND board_status(3) /= E) OR
--               (board_status(5) = board_status(7) AND board_status(5) /= E) OR
--               (board_status(3) = board_status(7) AND board_status(3) /= E) THEN
--                -- Win or defend
--                IF board_status(3) = E THEN
--                    ai_pos <= 3;
--                ELSIF board_status(5) = E THEN
--                    ai_pos <= 5;
--                ELSE
--                    ai_pos <= 7;
--                END IF;
            ELSIF board_status(5) = E THEN
                ai_pos <= 5;
            ELSIF board_status(1) = E THEN
                ai_pos <= 1;
            ELSIF board_status(3) = E THEN
                ai_pos <= 3;
            ELSIF board_status(7) = E THEN
                ai_pos <= 7;
            ELSIF board_status(9) = E THEN
                ai_pos <= 9;
            ELSIF board_status(2) = E THEN
                ai_pos <= 2;
            ELSIF board_status(4) = E THEN
                ai_pos <= 4;
            ELSIF board_status(6) = E THEN
                ai_pos <= 6;
            ELSIF board_status(8) = E THEN
                ai_pos <= 8;
            END IF;
        end if;
    end process;
    
--    rand_Computer_Move: PROCESS (board_status, blink_counter, my_seed) IS
--    variable rand_temp : integer;
--    begin
--        rand_temp := ((my_seed mod 9)+1);
--        if board_status(rand_temp) = E THEN
--            IF (blink_counter(25)= '0') AND (rising_edge(blink_counter(24))) THEN
--                ai_pos <= rand_temp;
--            end if;
--        end if;
--    end process;

END Behavioral;