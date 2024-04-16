# Battleship
.data
	# file name
	file_player_1:	.asciiz	"D:/test_BTL_KTMT/history_player_1.txt"
	file_player_2:	.asciiz	"D:/test_BTL_KTMT/history_player_2.txt"
	# grid 7x7
	grid_player_1: 		.byte	'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0'
	
	grid_player_2:		.byte	'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0'
			    	
	target_player_1:		.byte	'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0'
			    	
	target_player_2:		.byte	'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0',
			    		'0', '0', '0', '0', '0', '0', '0'		    		
	# Input
	ship: 			.space	100
	target: 			.space	100
	# Prompt
	prompt_player: 		.asciiz "Player *\n"
	prompt_count_ship:	.asciiz "You have * 2x1 ships, * 3x1 ships, and * 4x1 ship\n"
	prompt_type_ship:	.asciiz	"Choose a type ship (2,3,4)\n"
	prompt_location:		.asciiz "Enter the location of the bow and the stern of the ship (row col row1 col1)\n"
	prompt_turn_player: 	.asciiz "Turn player *. Enter target cell (row col)\n"
	prompt_grid_attack:	.asciiz	"Cells attacked by player *\n"
	# Error
	prompt_type_error:	.asciiz	"Type ship range from 2 to 4. Enter again\n"
	prompt_enough: 		.asciiz "You have used all *x1 ships. Enter again\n"
	prompt_location_error:	.asciiz	"Location range from 0 to 6. Enter again (row col row1 col1)\n"
	prompt_length_error:	.asciiz	"Please enter correct length of *x1 ship\n"
	prompt_overlap_error:	.asciiz "The ships are overlapping with each other. Enter again\n"
	prompt_target_error:	.asciiz	"Error location of the target cell. Enter again\n"
	# Output
	prompt_combat:		.asciiz "COMBAT!"
	prompt_hit:		.asciiz "HIT!\n"
	prompt_win:		.asciiz	"YOU WIN!!\n"
	# string dialog
	dialog:			.space 1000
	# write
	prompt_write_type:	.asciiz "Type ship: * "
	prompt_write_ship:	.asciiz "at location "

.text
.globl main

main:
	# open file
	li 	$v0, 13
	la 	$a0, file_player_1
	li 	$a1, 1
	li 	$a2, 0
	syscall
	move 	$s6, $v0
		
	li 	$v0, 13
	la 	$a0, file_player_2
	li 	$a1, 1
	li 	$a2, 0
	syscall
	move 	$s7, $v0
	# intial	
	li 	$s4, '1' # player 1
	la 	$k1, grid_player_1
	player:
	li 	$v0, 55
	la 	$a0, prompt_player
	sb 	$s4, 7($a0)
	li	$a1, 1
	syscall
	# input type ship
	li 	$s0, 3 # 2x1
	li 	$s1, 2 # 3x1
	li 	$s2, 1 # 4x1
	input:
	jal print_grid
	li 	$v0, 51
	la 	$a0, prompt_type_ship
	syscall
	jal input_type_ship
	# input location 
	li 	$v0, 54
	la 	$a0, prompt_location
	la 	$a1, ship
	li 	$a2, 8
	syscall
	jal input_location
	j combat
	
input_type_ship:
	move 	$s3, $a0
	beq	$a1, -1, type_error # cannot be correctly parsed
	beq 	$a1, -2, exit # cancel was chosen
	beq 	$a1, -3, type_error # ok was chosen but no data
	blt 	$a0, 2, type_error # <2
	bgt 	$a0, 4, type_error # >4
	jr	$ra
	
	update:
	beq 	$s3, 2, decrease_2x1
	beq 	$s3, 3, decrease_3x1
	beq 	$s3, 4, decrease_4x1
	decrease_2x1:
		beq 	$s0, 0, enough_type
		subi 	$s0, $s0, 1
		j	update_done
	decrease_3x1:
		beq 	$s1, 0, enough_type
		subi 	$s1, $s1, 1
		j	update_done
	decrease_4x1:
		beq 	$s2, 0, enough_type
		subi 	$s2, $s2, 1
		j	update_done
	enough_type:
		li 	$v0, 51
		la 	$a0, prompt_enough
		addi 	$t8, $s3, 48
		sb 	$t8, 18($a0)
		syscall
		j input_type_ship
	type_error:
		li 	$v0, 51
		la 	$a0, prompt_type_error
		syscall
		j input_type_ship
input_location:
	beq 	$a1, -2, input # cancel was chosen
	beq 	$a1, -3, location_error # oke but no data
	beq 	$a1, -4, location_error # maximum length
	la 	$a2, ship
	lb 	$t0, 0($a2)
	lb 	$t1, 1($a2)
	lb 	$t2, 2($a2)
	lb 	$t3, 3($a2)
	lb 	$t4, 4($a2)
	lb 	$t5, 5($a2)
	lb 	$t6, 6($a2)
	bne 	$t1, ' ', location_error
	bne 	$t3, ' ', location_error
	bne 	$t5, ' ', location_error
	blt 	$t0, '0', location_error
	bgt	$t0, '6', location_error
	blt 	$t2, '0', location_error
	bgt	$t2, '6', location_error
	blt 	$t4, '0', location_error
	bgt 	$t4, '6', location_error
	blt 	$t6, '0', location_error
	bgt 	$t6, '6', location_error
	beq 	$t0, $t4, if
	j else 
		if:
			beq 	$t2, $t6, length_error
			sub 	$t7, $t2, $t6
			abs 	$t7, $t7
			addi 	$t7, $t7, 1
			bne 	$t7, $s3, length_error
			subi 	$t0, $t0, '0'
			subi 	$t2, $t2, '0'
			subi 	$t4, $t4, '0'
			subi 	$t6, $t6, '0'
			move 	$t7, $t2
				check_overlap:
				mul 	$t8, $t0, 7
				add 	$t8, $t8, $t7 
				add 	$t8, $t8, $k1
				lb 	$t8, 0($t8)
				beq 	$t8, '1', overlap_error
				beq 	$t7, $t6, update_ship
				bgt 	$t7, $t6, greater
				addi 	$t7, $t7, 1
				condition:
				j check_overlap 
				greater:
					subi 	$t7, $t7, 1
					j condition
				update_ship:
				mul 	$t8, $t0, 7
				add 	$t8, $t8, $t2
				add 	$t8, $t8, $k1
				li 	$t9, '1'
				sb 	$t9, 0($t8)
				beq 	$t2, $t6, check
				bgt 	$t2, $t6, greater1
				addi 	$t2, $t2, 1
				condition1:
				j update_ship 
				greater1:
					subi 	$t2, $t2, 1
					j condition1
		else:
			bne 	$t2, $t6, length_error
			sub 	$t7, $t0, $t4
			abs 	$t7, $t7
			addi 	$t7, $t7, 1
			bne 	$t7, $s3, length_error
			subi 	$t0, $t0, '0'
			subi 	$t2, $t2, '0'
			subi 	$t4, $t4, '0'
			subi 	$t6, $t6, '0'
			move 	$t7, $t0
				check_overlap1:
				mul 	$t8, $t7, 7
				add 	$t8, $t8, $t2 
				add 	$t8, $t8, $k1
				lb 	$t8, 0($t8)
				beq 	$t8, '1', overlap_error
				beq 	$t7, $t4, update_ship1
				bgt 	$t7, $t4, greater2
				addi 	$t7, $t7, 1
				condition2:
				j check_overlap1 
				greater2:
					subi 	$t7, $t7, 1
					j condition2
				update_ship1:
				mul 	$t8, $t0, 7
				add 	$t8, $t8, $t2
				add 	$t8, $t8, $k1
				li 	$t9, '1'
				sb 	$t9, 0($t8)
				beq 	$t0, $t4, check
				bgt 	$t0, $t4, greater3
				addi 	$t0, $t0, 1
				condition3:
				j update_ship1 
				greater3:
					subi 	$t0, $t0, 1
					j condition3
			
	location_error:
		li 	$v0, 54
		la 	$a0, prompt_location_error
		la 	$a1, ship
		li 	$a2, 8
		syscall
		j input_location
	length_error:
		li 	$v0, 54
		la 	$a0, prompt_length_error
		addi 	$t8, $s3, 48
		sb 	$t8, 31($a0)
		la 	$a1, ship
		li 	$a2, 8
		syscall
		j input_location
	overlap_error:
		li 	$v0, 54
		la 	$a0, prompt_overlap_error
		la 	$a1, ship
		li 	$a2, 8
		syscall
		j input_location

	check:
		beq 	$s4, '1', write_ship
		
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, prompt_write_type
		add 	$s5, $s3, 48
		sb 	$s5, 11($a1)
		li 	$a2, 13
		syscall
	
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, prompt_write_ship
		li 	$a2, 12
		syscall
		
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, ship
		li 	$a3, '\n'
		sb 	$a3, 7($a1)
		li 	$a2, 8
		syscall
		j write_ship_done
			write_ship:
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, prompt_write_type
				add 	$s5, $s3, 48
				sb 	$s5, 11($a1)
				li 	$a2, 13
				syscall
			
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, prompt_write_ship
				li 	$a2, 12
				syscall
				
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, ship
				li 	$a3, '\n'
				sb 	$a3, 7($a1)
				li 	$a2, 8
				syscall
				j write_ship_done
		write_ship_done:
		j	update
		update_done:
		seq 	$a0, $s0, 0
		seq 	$a1, $s1, 0
		seq 	$a2, $s2, 0
		and 	$a0, $a0, $a1
		and 	$a0, $a0, $a2 # a0 = (s0=s1=s2=0)?1:0
		beq 	$a0, 0, input
		addi 	$s4, $s4, 1
		la 	$k1, grid_player_2
		beq 	$s4, '2', player
		jr 	$ra

combat:
	li 	$v0, 55
	la 	$a0, prompt_combat
	li 	$a1, 1
	syscall
	
	combat_player_1:
	li 	$t8, '1'
	la 	$t9, grid_player_2
	la 	$k1, target_player_1
	j combat_player
	combat_player_2:
	li 	$t8, '2'
	la 	$t9, grid_player_1
	la 	$k1, target_player_2
	
	combat_player:
	jal print_grid
	li 	$v0, 54
	la 	$a0, prompt_turn_player
	sb 	$t8, 12($a0)
	la 	$a1, target
	li 	$a2, 4
	syscall
	j input_target
	

input_target:
	beq 	$a1, -2, exit # cancel was chosen
	beq 	$a1, -3, target_error # oke but no data
	beq 	$a1, -4, target_error # maximum length
	la 	$t0, target
	lb 	$t1, 0($t0)
	lb 	$t2, 1($t0)
	lb 	$t3, 2($t0)
	bne 	$t2, ' ', target_error
	blt 	$t1, '0', target_error
	bgt 	$t1, '6', target_error
	blt 	$t3, '0', target_error
	bgt 	$t3, '6', target_error
	subi 	$t1, $t1, '0'
	subi 	$t3, $t3, '0'
	mul 	$t4, $t1, 7
	add 	$t4, $t4, $t3
	add 	$t5, $t4, $t9
	lb 	$t7, 0($t5)
	beq 	$t7, '1', hit
	j check_win
	target_error:
		li 	$v0, 54
		la 	$a0, prompt_target_error
		la 	$a1, target
		li 	$a2, 4
		syscall
		j input_target
	hit:
		# update grid
		add 	$t6, $t4, $k1
		sb 	$t7, 0($t6)
		li 	$t7, '0'
		sb 	$t7, 0($t5)
		
		li 	$v0, 55
		la 	$a0, prompt_hit
		li 	$a1, 1
		syscall
		j check_win
	check_win:
		li 	$s0, 1
		loop:
		lb 	$t1, 0($t9)
		beq 	$t1, '1', turn
		addi 	$t9, $t9, 1
		beq 	$s0, 49, win
		addi 	$s0, $s0, 1
		j loop
	turn:
		beq 	$t8, '1', write_target
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, target
		li 	$a3, '\n'
		sb 	$a3, 3($a1)
		li 	$a2, 4
		syscall
		j write_target_done
			write_target:
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, target
				li 	$a3, '\n'
				sb 	$a3, 3($a1)
				li 	$a2, 4
				syscall
		write_target_done:
		beq 	$t8, '1', combat_player_2
		j combat_player_1
	win:
		beq 	$t8, '1', write_target_win
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, target
		li 	$a3, '\n'
		sb 	$a3, 3($a1)
		li 	$a2, 4
		syscall
		
		li 	$v0, 15
		move 	$a0, $s7
		la 	$a1, prompt_win
		li 	$a2, 9
		syscall
		j write_target_win_done
			write_target_win:
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, target
				li 	$a3, '\n'
				sb 	$a3, 3($a1)
				li 	$a2, 4
				syscall
				
				li 	$v0, 15
				move 	$a0, $s6
				la 	$a1, prompt_win
				li 	$a2, 9
				syscall
		write_target_win_done:
		
		li 	$v0, 55
		la 	$a0, prompt_win
		li 	$a1, 1
		syscall
		j exit
print_grid:
	move 	$t3, $k1
	la 	$k0, dialog
	
	li 	$t0, 0
	li 	$t2, ' '
	line_tmp2:
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, 6, line_tmp2
	
	li 	$t0, '0'
	line_index:
	sb 	$t2, 0($k0)
	sb 	$t2, 1($k0)
	sb 	$t2, 2($k0)
	sb	$t0, 3($k0)
	addi	$k0, $k0, 4
	addi 	$t0, $t0, 1
	bne 	$t0, '7', line_index

	li 	$t2, '\n'
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	
	li 	$t0, 0
	li 	$t2, ' '
	line_tmp:
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, 5, line_tmp
	
	li 	$t0, 0
	li 	$t2, '-'
	line_head:
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, 32, line_head
	
	li 	$t2, '\n'
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	
	li 	$t0, '0'
	line:
	sb	$t0, 0($k0)
	li 	$t2, ' '
	sb 	$t2, 1($k0)
	sb 	$t2, 2($k0)
	sb 	$t2, 3($k0)
	addi 	$k0, $k0, 4

	li 	$t2, '|'
	sb 	$t2, 0($k0)
	li 	$t2, ' '
	sb 	$t2, 1($k0)
	sb 	$t2, 2($k0)
	sb 	$t2, 3($k0)
	addi 	$k0, $k0, 4
	
	li 	$t1, 0
	line_grid:
	lb 	$t2, 0($t3)
	sb 	$t2, 0($k0)
	li 	$t2, ' '
	sb 	$t2, 1($k0)
	sb 	$t2, 2($k0)
	sb 	$t2, 3($k0)
	addi 	$t3, $t3, 1
	addi 	$k0, $k0, 4
	addi 	$t1, $t1, 1
	bne 	$t1, 7, line_grid
	
	li 	$t2, '|'
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	
	li 	$t2, '\n'
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, '7', line
	
	li 	$t0, 0
	li 	$t2, ' '
	line_tmp1:
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, 5, line_tmp1
	
	li 	$t0, 0
	li 	$t2, '-'
	line_end:
	sb 	$t2, 0($k0)
	addi 	$k0, $k0, 1
	addi 	$t0, $t0, 1
	bne 	$t0, 32, line_end
	
	li 	$v0, 59
	beq 	$s4, '3', print_combat
	la 	$a0, prompt_count_ship
	addi 	$t0, $s0, 48
	addi 	$t1, $s1, 48
	addi 	$t2, $s2, 48
	sb 	$t0, 9($a0)
	sb 	$t1, 22($a0)
	sb 	$t2, 39($a0)
	j print
	print_combat:
	la 	$a0, prompt_grid_attack
	sb 	$t8, 25($a0)
	print:
	la 	$a1, dialog
	syscall
	jr 	$ra
exit:	
        # close_file
	li 	$v0, 16              
        move	$a0, $s6           
        syscall 
        
        li 	$v0, 16              
        move 	$a0, $s7          
        syscall 
        # exit
	li 	$v0, 10
	syscall
	
