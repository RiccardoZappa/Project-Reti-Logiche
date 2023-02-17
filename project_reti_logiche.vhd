----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.11.2022 23:14:27
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity project_reti_logiche is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_start : in std_logic;
            i_data : in std_logic_vector(7 downto 0);
            o_address : out std_logic_vector(15 downto 0);
            o_done : out std_logic;
            o_en : out std_logic;
            o_we : out std_logic;
            o_data : out std_logic_vector (7 downto 0)
             );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

TYPE fsm_state IS (RESET,
	IDLING,
	READ_NWORD,
	SETTING_ADDRESS,
	READ_WORD,
	PRE_CONV,
	CONVOLUTION,
	POST_CONV,
	SENDER1,
	SENDER2,
	FINALIZE
	);


type s is (s0,s1,s2,s3);
signal cur_state : s;
signal curr_state : fsm_state;
SIGNAL n_word : std_logic_vector(7 DOWNTO 0);
signal count_i :  std_logic_vector(15 DOWNTO 0);
SIGNAL count_o : std_logic_vector(15 DOWNTO 0);
signal word : std_logic_vector (7 downto 0);
signal uk,p1k,p2k : std_logic;
signal word_to_send : std_logic_vector (15 downto 0);
signal count : integer ;
BEGIN
	UNIQUE_PROCESS : PROCESS (i_clk)
	
	BEGIN
		IF i_clk'EVENT AND i_clk = '0' THEN
			IF i_rst = '1' THEN
				-- stato attuale della macchina a stati
				curr_state <= RESET;
			ELSE
			   
				CASE curr_state IS
				
				
					WHEN RESET =>
						o_en <= '0';
						o_we <= '0';
						o_data <= "00000000";
						o_done <= '0';
						curr_state <= RESET;
						o_address <= "0000000000000000";
						count_i <= "0000000000000001";
						count_o <= "0000000000000000";
						cur_state <= s0;
						count <=7;
                        curr_state <= IDLING;


                    
					WHEN IDLING =>
					    IF i_start = '1' THEN
							o_en <= '1';
							curr_state <= READ_NWORD;
						END IF;
						
						
					WHEN READ_NWORD =>
						n_word <= i_data;
			
						curr_state <= SETTING_ADDRESS;
					   
					WHEN SETTING_ADDRESS =>    
					   if n_word = "00000000" then
                           o_done <= '1';
                           curr_state <= FINALIZE;
					   else
					   o_we <= '0';
					   o_address <= "0000000000000000" + count_i;
					  
					   curr_state <= READ_WORD;
						end if;
						
					WHEN READ_WORD =>
					   count_i <= count_i + 1;
						word <= i_data;
						curr_state <= PRE_CONV;
					WHEN PRE_CONV =>
					   
					   uk <= word(count);
					   curr_state <= CONVOLUTION;
						
				    WHEN CONVOLUTION =>
				         uk <= word(count);
				        case cur_state is 
				            when s0 =>
				                if uk = '0' then
				                    p1k <= '0';
				                    p2k <= '0';
				                    cur_state <= s0;
				                else 
				                    p1k <= '1';
                                    p2k <= '1';
                                    cur_state <= s2;
                                end if;
                               
				            when s1 =>
				                if uk = '0' then
                                  p1k <= '1';
                                  p2k <= '1';
                                  cur_state <= s0;
				                else 
                                   p1k <= '0';
                                   p2k <= '0';
                                   cur_state <= s2;
                                end if;
                                
   				            when s2 =>
				                if uk = '0' then
                                    p1k <= '0';
                                    p2k <= '1';
                                    cur_state <= s1;
				                else 
                                    p1k <= '1';
                                    p2k <= '0';
                                    cur_state <= s3;
                                end if;
                                
				            when s3 =>
				                if uk = '0' then
                                   p1k <= '1';
                                   p2k <= '0';
                                   cur_state <= s1;
                                 else 
                                    p1k <= '0';
                                    p2k <= '1';
                                    cur_state <= s3;
				                 end if;
				                 
				            end case;
				            curr_state <= POST_CONV;
				            
				        when POST_CONV => 
				             word_to_send(count + count +1) <= p1k;
                             word_to_send(count + count) <= p2k;
                             if count > 0 then
                                   count <= count -1;
                                   curr_state <=PRE_CONV;
                          
                             else count <= 7;
                                  curr_state <= SENDER1;
                           
                             end if;
                            
				        
                        when SENDER1 => 
                            o_en <='1';
                            o_we <= '1';
                            o_address <= "0000001111101000" + count_o;
                            o_data <= word_to_send(15 downto 8);
                            count_o <= count_o + 1;
                            curr_state <= SENDER2;
                        
                        when SENDER2 =>
                            o_address <= "0000001111101000" + count_o;
                            o_data <= word_to_send(7 downto 0);
                            count_o <= count_o + 1;
                            if count_i -1 = n_word  then
                                o_done <= '1';
                                curr_state <= FINALIZE;
                            else curr_state <= SETTING_ADDRESS;
                            end if;
                            
                        when FINALIZE => 
                            IF (i_start = '0') THEN
                                    o_done <= '0';
                                    curr_state <= RESET;
                            ELSE
                                    o_done <= '0';
                                     o_we <= '0';
                           END IF;

                        end case;
                    end if;
              end if;
    end process;

end Behavioral;
