----------------------------------------------------------------------------------
-- Company: 
-- Engineer: fpgaddicted (Stefan Naco)
-- 
-- Create Date:    20:00:44 05/06/2017 
-- Design Name: 
-- Module Name:    ram_control_fsm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity stack_control_fsm is
    Port ( empty_flag : out  STD_LOGIC;
           full_flag : out  STD_LOGIC;
           overflow_flag : out  STD_LOGIC;
           clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  push, pop : in STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (4 downto 0);
           we : out STD_LOGIC_VECTOR (0 downto 0));
end stack_control_fsm;

architecture FSM of stack_control_fsm is

signal tos: std_logic_vector(4 downto 0);
type state is (empty,normal_op,overflow,push_w,push_nw,pop_r,pop2);
signal s : state; -- (7 state FSM for sequential operation and flag output) 

begin
	process(clk)
	begin
	if rising_edge(clk) then
		if reset ='1' then -- initialize state and stack pointer
			tos <= "00000";
			we <= "0";
			s <= empty;
		else
			case s is       --> Finite State Machine on duty <--
				when empty=>
					if push ='1' then
						s <= push_w;	
					else
						s <= empty;   -- pop is not allowed on an empty stack					
					end if;
					
			-- push / pop process--		
				when push_w =>      -- push_write (WE = 1)
					we <= "1";
					s <= push_nw; 
				when push_nw =>     -- push_not write (WE = 0)
					we <= "0";  
					tos <= tos+1;    -- increase sp by 1 (post increment)
					s <= normal_op;  -- go to normal state and wait for input)
				when pop_r =>
					tos <= tos-1;    -- decrease sp by 1 (pre decrement)
					s<= pop2;   
				when pop2 => 
				   s<= normal_op;   -- go to normal state and wait for input					
			-- end process	--
			
				when normal_op =>
					if push = '1' then
							if tos = "11111" then -- check for full stack
								s<= overflow;
							else 
								s <= push_w;       -- push till overflow
							end if;
					elsif pop = '1' then
							if tos = "00000" then -- check for empty stack
								s <= empty;        -- pop till empty stack
							else
								s<= pop_r;
							end if;
					end if;
				
				when overflow =>  
					if reset = '1' then
						s <= empty;   -- go to initial condition (empty stack)
					else
						s <= overflow;
					end if;
				end case;
			end if;
		end if;
	end process;
	address <= tos;  -- write sp to address
	
	overflow_flag <= '1' when s = overflow else '0';
	full_flag <= '1' when tos = 30 else '0';
	empty_flag <= '1' when s = empty else '0';
					
end FSM;

