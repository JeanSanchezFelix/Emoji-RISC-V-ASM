.data
r1:
    # Circle pattern
    .word 0b0000000000000000   
    .word 0b0000111111110000 
    .word 0b0001111111111000 
    .word 0b0011111111111100 
    .word 0b0111111111111110   
    .word 0b1111111111111111   
    .word 0b1111111111111111   
    .word 0b1111111111111111   
    .word 0b1111111111111111   
    .word 0b1111111111111111   
    .word 0b1111111111111111   
    .word 0b0111111111111110   
    .word 0b0011111111111100   
    .word 0b0001111111111000   
    .word 0b0000111111110000   
    .word 0b0000011111100000   

r2: 
    # Outline pattern
    .word 0b0000111111110000   
    .word 0b0001000000001000   
    .word 0b0010000000000100   
    .word 0b0100000000000010   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b1000000000000001   
    .word 0b0100000000000010   
    .word 0b0010000000000100   
    .word 0b0001000000001000   
    .word 0b0000111111110000   



# Position variables
pos_x: .word 5
pos_y: .word 5

.text
main:
    li s0, LED_MATRIX_0_BASE
    li s1, LED_MATRIX_0_WIDTH
    li s2, LED_MATRIX_0_HEIGHT

    jal ra, clear_screen
    jal ra, draw_emoji



# Main loop
main_loop:
    j main_loop


clear_screen:
    mv t1, zero
    mv t2, s0
clear_rows:
    mv a5, t2
    mv a3, s1
clear_cols:
    li t0, 0xFFFFFF          # White BG
    sw t0, 0(a5)
    addi a3, a3, -1
    addi a5, a5, 4
    bnez a3, clear_cols
    addi t1, t1, 1
    slli t0, s1, 2
    add t2, t2, t0
    bne t1, s2, clear_rows
    jr ra



draw_emoji:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Load the position
    la t0, pos_x
    lw a2, 0(t0)  # pos_x
    la t0, pos_y
    lw a3, 0(t0)  # pos_y
    
    # Draw r1 circle pattern
    li t4, 0xFFD700  
    la t0, r1        
    li t1, 0      # row index      

circle_row_loop:
    li t2, 0                        # col index
    lw t3, 0(t0)                    # load row pattern
circle_col_loop:
    andi a7, t3, 1   
    bnez a7, draw_pixel             # if 1 draw, else skip
    j next_col
draw_pixel:
    add a0, a3, t1                  # y = pos_y + row
    add a1, a2, t2                  # x = pos_x + col
    jal ra, px_plot
next_col:
    addi t2, t2, 1
    srli t3, t3, 1                  # shift right
    li a6, 16  
    blt t2, a6, circle_col_loop
    addi t0, t0, 4                  # next row
    addi t1, t1, 1
    li a5, 16 
    blt t1, a5, circle_row_loop

    # Draw closed eyes 
    li t4, 0x000000  

    # Left eye
    addi a0, a3, 8
    addi a1, a2, 3
    jal ra, px_plot
    addi a0, a3, 4
    addi a1, a2, 3
    jal ra, px_plot
    addi a0, a3, 6
    addi a1, a2, 5
    jal ra, px_plot
    addi a0, a3, 5
    addi a1, a2, 4
    jal ra, px_plot
    addi a0, a3, 7
    addi a1, a2, 4
    jal ra, px_plot

    # Right eye
    addi a0, a3, 6
    addi a1, a2, 10
    jal ra, px_plot
    addi a0, a3, 5
    addi a1, a2, 11
    jal ra, px_plot
    addi a0, a3, 7
    addi a1, a2, 11
    jal ra, px_plot
    addi a0, a3, 8
    addi a1, a2, 12
    jal ra, px_plot
    addi a0, a3, 4
    addi a1, a2, 12
    jal ra, px_plot

    # Mouth
    addi a0, a3, 12         # initial pos y
    li t0, 4                # start x 
    li t1, 11               # end x 

mouth_loop:
    add a1, a2, t0          # initial pos x
    jal ra, px_plot
    addi t0, t0, 1
    ble t0, t1, mouth_loop

    # Mouth smiley corners 
    addi a0, a3, 11  
    addi a1, a2, 3   
    jal ra, px_plot

    addi a0, a3, 11  
    addi a1, a2, 12  
    jal ra, px_plot


# Draw r2 outline pattern 
la t0, r2        
li t1, 0         # row index

outline_row_loop:
    li t2, 0                    # col index
    lw t3, 0(t0)                # load row pattern
outline_col_loop:
    andi t5, t3, 1   
    beqz t5, next_outline_col   
    
    sub t5, t1, t2              # calculate row - col (flipped Y-axis)
    li t6, 0                    
    ble t5, t6, light_color     # if row - col <= 0, use light color
    
    # Shadow color (bottom-left half)
    li t4, 0xCCAA00         
    j plot_outline
    
light_color:
    # Light color (top-right half)
    li t4, 0xE7C170         

plot_outline:
    add a0, a3, t1                  # y = pos_y + row
    add a1, a2, t2                  # x = pos_x + col
    jal ra, px_plot
    
next_outline_col:
    srli t3, t3, 1                  # shift right
    addi t2, t2, 1
    li t5, 16
    blt t2, t5, outline_col_loop
    addi t0, t0, 4                  # next row
    addi t1, t1, 1
    li t6, 16
    blt t1, t6, outline_row_loop

    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


# Helper pixel plotter 
px_plot:
    # find address: base + (y * width + x) * 4
    mul a7, a0, s1
    add a7, a7, a1
    slli a7, a7, 2      # offset by 4
    add a7, a7, s0
    sw t4, 0(a7)        # write color
    jr ra