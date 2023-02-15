# This example demonstrates an implementation of LCS's algorithm for finding longest common subsequences.
# We provided two strings in global for simplfy.
# Reference link : https://www.geeksforgeeks.org/longest-common-subsequence-dp-4/
# The ouput of test pattern 1 should be =>  Found LCS length : 8 
# The ouput of test pattern 2 should be =>  Found LCS length : 13

.data
.align 4
# test pattern 1
SequenceA: .string "ACGTTCGCGACA"
SequenceB: .string "ATCGATGCGC"
SASize: .word 12
SBSize: .word 10
# test pattern 2
#SequenceA: .string "ACGTTTGTAACGACA"
#SequenceB: .string "ACGTCTGTAACGTCCACGCTC"
#SASize: .word 15
#SBSize: .word 21
str: .string "Found LCS length "
newline: .string "\n"
i: .word 0
j: .word 0
L: .word 1024
.text
.global _start
# Start your coding below, don't change anything upper.

_start:

    la a0 SequenceA
    la a1 SequenceB
    lw a2 i
    lw a3 j 
    la a4 L
    lw a5 SASize
    lw a6 SBSize
    
    jal lcs
    
    #print str
    la a0, str
    li a7, 4
    ecall
    #print a0
    mv a0 t0
    li a7 1
    ecall
    #print \n
    la a0, newline
    li a7, 4
    ecall

    j end
    
lcs:    

    addi sp, sp, -4
    sw ra, 0(sp) # return address
    addi a2 a2 -1 #set i=-1 first
    
First_for:
    addi a2 a2 1 #i=i+1
    bgt a2 a5 exit 
    addi a3 x0 0 #set j=0
Second_for:
    #jump to First_for if j > SBSize
    bgt a3 a6 First_for
    #jump to condition one if i=0 ||  j=0
    beq a2 zero condition1
    bne a3 zero condition2 
condition1:
    addi t0 a6 1
    mul t0 t0 a2 #t0=(SBSize+1)*i
    add t1 t0 a3 #t1=(SBSize+1)*i+j
    slli t1 t1 2 #t1=((SBSize+1)*i+j)*4 RAW Hazard
    add t1 a4 t1 #t1=((SBSize+1)*i+j)*4+a4
    sw x0 0(t1) #L[i][j]=0
    addi a3 a3 1 #j=j+1
    beq x0 x0 Second_for
condition2:
    addi t2 a2 -1 #t2=i-1
    addi t3 a3 -1 #t3=j-1
    add t0 a0 t2 #t0=SequenceA+i-1
    add t1 a1 t3 #t1=SequenceB+j-1
    lb t0 0(t0) #t0=SequenceA[i-1]
    lb t1 0(t1) #t1=SequenceB[j-1]
    bne t0 t1 condition3 
  
    addi t0 a6 1
    mul t0 t0 a2 #t0=(SBSize+1)*i
    add t1 t0 a3 #t1=(SBSize+1)*i+j
    slli t1 t1 2 #t1=((SBSize+1)*i+j)*4 RAW Hazard
    add t1 a4 t1 #t1=[(SBSize+1)*i+j]*4+a4
  
    addi t0 a6 1
    mul t2 t0 t2 #t2=(SBSize+1)*(i-1)
    add t3 t2 t3 #t3-[(SBSize+1)*(i-1)+(j-1)]
    slli t3 t3 2 #t3=[(SBSize+1)*(i-1)+(j-1)]*4  RAW Hazard
    add t3 a4 t3 #t3=[(SBSize+1)*(i-1)+(j-1)]*4+a4 
    lw t3 0(t3) #t3=L[i-1][j-1]
    addi t3 t3 1 #t3=t3+1
    sw t3 0(t1) #L[i][j]=L[i-1][j-1]+1
    
    addi a3 a3 1 #j=j+1
    beq x0 x0 Second_for
condition3:
    addi t0 a6 1 #t0=(SBSize+1)
    mul t0 t0 a2 #t0=(SBSize+1)*i
    add t1 t0 a3 #t1=(SBsize+1)*i+j
    slli t1 t1 2 #t1=((SBSize+1)*i+j)*4 RAW Hazard
    mv t0 t1 #t0=((SBSize+1)*i+j)*4
    add t1 a4 t1 #t1=((SBSize+1)*i+j)*4+a4  
    
    addi t2 a6 1 #t2=(SBSize+1)
    slli t2 t2 2 #t2=(SBSize+1)*4
    sub t2 t0 t2 #t2=[(SBSize+1)*(i-1)+j]*4  RAW Hazard
    add t2 a4 t2 #t2=[(SBSize+1)*(i-1)+j]*4+a4  WAW Hazard
    lw t2 0(t2) #t2=L[i-1][j]   LOAD Hazard
    
    addi t4 t0 -4 #t4=[(SBSize+1)*i+(j-1)]*4
    add t4 a4 t4 #t4=[(SBSize+1)*i+(j-1)]*4+a4  WAW Hazard
    lw t4 0(t4) #t4=L[i][j-1]   LOAD Hazard
    
    
    sub t5 t2 t4
    bge t5 zero index
    sw t4 0(t1) #L[i][j]=t2=L[i][j-1]
    beq x0 x0 exit_condition3
index:
    sw t2 0(t1) #L[i][j]=t2=L[i-1][j]
    
exit_condition3: 
    addi a3 a3 1 #j=j+1
    beq x0 x0 Second_for

 
exit:
    addi a5 a5 1
    addi a6 a6 1
    mul t0 a5 a6 #t0=(SASize+1)*(SBSize+1)
    slli t0 t0 2 #t0=(SASize+1)*(SBSize+1)*4
    addi t0 t0 -4 #t0=(SASize+1)*(SBSize+1)*4-4 the last word
    add a4 a4 t0 #a4=a4+t0
    lw a0 0(a4) #a0=L[SASize][SBSize]  
    lw   ra, 0(sp) # Reload return address from stack
    add t0 x0 a0
    addi sp, sp, 4 # Restore stack pointer
    jr x1


end:nop
