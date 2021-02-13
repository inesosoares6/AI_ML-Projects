import numpy as np

#Data
BOARD_ROWS = 3
BOARD_COLS = 4
WIN_STATE = (0, 3)
LOSE_STATE = (1, 3)
FORBIDDEN_STATE = (1,1)
START = (2, 0)
REWARD_TERMINAL_POS = 1
REWARD_TERMINAL_NEG = -1
REWARD_NORMAL = -0.04
DISCOUNT_FACTOR = 1
P1 = 0.8
P2 = 0.1
P3 = 0.1

#Initialization
board = np.zeros([BOARD_ROWS, BOARD_COLS])
board[(WIN_STATE)]=REWARD_TERMINAL_POS
board[(LOSE_STATE)]=REWARD_TERMINAL_NEG
future_value = np.zeros([BOARD_ROWS, BOARD_COLS])
future_value[(WIN_STATE)]=REWARD_TERMINAL_POS
future_value[(LOSE_STATE)]=REWARD_TERMINAL_NEG
f = open("datafile_I1.txt", "w")
f.write("")
f.close()
aux=np.zeros(4)

#Calculate Utilities
m=1
while True:
    delta=0
    for i in range(0,BOARD_ROWS):
        for j in range(0,BOARD_COLS):
            if (i-1,j)==FORBIDDEN_STATE:
                board[(i-1,j)]=board[(i,j)]
            if (i+1,j)==FORBIDDEN_STATE:
                board[(i+1,j)]=board[(i,j)]
            if (i,j-1)==FORBIDDEN_STATE:
                board[(i,j-1)]=board[(i,j)]
            if (i,j+1)==FORBIDDEN_STATE:
                board[(i,j+1)]=board[(i,j)]
            if (i, j) != WIN_STATE and (i, j) != LOSE_STATE and (i,j) != FORBIDDEN_STATE:
                if i==0 and j==0: #Corner 1
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif i==0 and j==BOARD_COLS-1: #Corner 2
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j-1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j-1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif i==BOARD_ROWS-1 and j==0: #Corner 3
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif i==BOARD_ROWS-1 and j==BOARD_COLS-1: #Corner 4
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif i==0 and j!=0 and j!=BOARD_COLS-1: #Wall 1
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif i==BOARD_ROWS-1 and j!=0 and j!=BOARD_COLS-1: #Wall 2
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif  j==0 and i!=0 and i!=BOARD_ROWS-1: #Wall 3
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                elif  j==BOARD_COLS-1 and i!=0 and i!=BOARD_ROWS-1: #Wall 4
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
                else:
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                        k+=1
                    future_value[(i,j)]=round(max_val,4)
            f = open("datafile_I1.txt", "a")
            f.write(str(m)+";"+str(future_value[(i,j)])+";"+str((i,j))+"\n")
            f.close()
    board[(FORBIDDEN_STATE)]=0
    aux1=np.abs(future_value-board)
    aux_delta=aux1.max()
    delta=max(delta,aux_delta)
    board=future_value.copy()
    m+=1
    if(delta<0.001):
        print(m-1)
        break

#Print Utilities
for i in range(0, BOARD_ROWS):
    print('-----------------------------------------')
    out = '| '
    for j in range(0, BOARD_COLS):
        out += str(board[(i, j)]).ljust(7) + ' | '
    print(out)
print('-----------------------------------------')

#Print Policies
for i in range(0, BOARD_ROWS):
    print('------------------------')
    out = '| '
    for j in range(0, BOARD_COLS):
        if (i-1,j)==FORBIDDEN_STATE:
            board[(i-1,j)]=board[(i,j)]
        if (i+1,j)==FORBIDDEN_STATE:
            board[(i+1,j)]=board[(i,j)]
        if (i,j-1)==FORBIDDEN_STATE:
            board[(i,j-1)]=board[(i,j)]
        if (i,j+1)==FORBIDDEN_STATE:
            board[(i,j+1)]=board[(i,j)]
        if (i,j) != FORBIDDEN_STATE and (i, j) != WIN_STATE and (i, j) != LOSE_STATE:
            if i==0 or i==BOARD_ROWS-1 or j==0 or j==BOARD_COLS-1:
                if i==0 and j==0: #Corner 1
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6) 
                elif i==0 and j==BOARD_COLS-1: #Corner 2
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j-1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j-1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6) 
                elif i==0 and j!=0 and j!=BOARD_COLS-1: #Wall 1
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6)
                elif i==BOARD_ROWS-1 and j!=0 and j!=BOARD_COLS-1: #Wall 2
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6)
                elif i==BOARD_ROWS-1 and j==0: #Corner 3
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6) 
                elif i==BOARD_ROWS-1 and j==BOARD_COLS-1: #Corner 4
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6)
                elif  j==0 and i!=0 and i!=BOARD_ROWS-1: #Wall 3
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6)
                elif  j==BOARD_COLS-1 and i!=0 and i!=BOARD_ROWS-1: #Wall 4
                    aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                    aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                    aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                    aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                    max_val=aux[0]
                    k=0
                    b=0
                    while k<4:
                        if(aux[k]>max_val):
                            max_val=aux[k]
                            b=k
                        k+=1
                    if(b==0):
                        out += str(' v | ').ljust(6) 
                    elif(b==1):
                        out += str(' ^ | ').ljust(6) 
                    elif(b==2):
                        out += str(' > | ').ljust(6) 
                    else:
                        out += str(' < | ').ljust(6) 
            else:
                aux[0]=DISCOUNT_FACTOR*(P1*board[(i+1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # v 
                aux[1]=DISCOUNT_FACTOR*(P1*board[(i-1, j)]+P2*board[(i, j+1)]+P3*board[(i, j-1)])+REWARD_NORMAL # ^
                aux[2]=DISCOUNT_FACTOR*(P1*board[(i, j+1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # >
                aux[3]=DISCOUNT_FACTOR*(P1*board[(i, j-1)]+P2*board[(i+1, j)]+P3*board[(i-1, j)])+REWARD_NORMAL # <
                max_val=aux[0]
                k=0
                b=0
                while k<4:
                    if(aux[k]>max_val):
                        max_val=aux[k]
                        b=k
                    k+=1
                if(b==0):
                    out += str(' v | ').ljust(6) 
                elif(b==1):
                    out += str(' ^ | ').ljust(6) 
                elif(b==2):
                    out += str(' > | ').ljust(6) 
                else:
                    out += str(' < | ').ljust(6)
        elif (i, j) == WIN_STATE:
            out += str(' 1 |').ljust(6) 
        elif (i, j) == LOSE_STATE:
            out += str('-1 |').ljust(6) 
        elif (i,j) == FORBIDDEN_STATE:
            out += str(' F |').ljust(6) 
    print(out)
board[(FORBIDDEN_STATE)]=0
print('------------------------')