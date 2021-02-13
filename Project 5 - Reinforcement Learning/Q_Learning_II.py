import numpy as np

BOARD_ROWS = 4
BOARD_COLS = 4
WIN_STATE = (3, 3)
SPECIAL_STATE = (2, 2)
START = (3, 0)
FORBIDDEN_STATE=(3,2)
REWARD_TERMINAL_POS = 100
REWARD_SPECIAL_STATE = -20
REWARD_NORMAL = -1
DISCOUNT_FACTOR=0.99
EXPLORATION=0.2 # 0.05 or 0.2
DETERMINISTIC = False
P1=0.8
P2=0.1
P3=0.1


class State:
    def __init__(self, state=START):
        self.board = np.zeros([BOARD_ROWS, BOARD_COLS])
        self.board[3, 2] = -1
        self.state = state
        self.isEnd = False
        self.determine = DETERMINISTIC

    def giveReward(self):
        if self.state == WIN_STATE:
            return REWARD_TERMINAL_POS
        elif self.state == SPECIAL_STATE:
            return REWARD_SPECIAL_STATE
        else:
            return REWARD_NORMAL

    def isEndFunc(self):
        if (self.state == WIN_STATE):
            self.isEnd = True

    def _chooseActionProb(self, action):
        if action == "up":
            return np.random.choice(["up", "left", "right"], p=[P1, P2, P3])
        if action == "down":
            return np.random.choice(["down", "left", "right"], p=[P1, P2, P3])
        if action == "left":
            return np.random.choice(["left", "up", "down"], p=[P1, P2, P3])
        if action == "right":
            return np.random.choice(["right", "up", "down"], p=[P1, P2, P3])

    def nxtPosition(self, action):
        if self.determine:
            if action == "up":
                nxtState = (self.state[0] - 1, self.state[1])
            elif action == "down":
                nxtState = (self.state[0] + 1, self.state[1])
            elif action == "left":
                nxtState = (self.state[0], self.state[1] - 1)
            else:
                nxtState = (self.state[0], self.state[1] + 1)
            self.determine = False
        else:
            action = self._chooseActionProb(action)
            self.determine = True
            nxtState = self.nxtPosition(action)

        # if next state is legal
        if (nxtState[0] >= 0) and (nxtState[0] <= BOARD_ROWS-1):
            if (nxtState[1] >= 0) and (nxtState[1] <= BOARD_COLS-1):
                if nxtState != FORBIDDEN_STATE:
                    return nxtState
        return self.state

class Agent:

    def __init__(self):
        self.states = []  # record position and action taken at the position
        self.actions = ["up", "down", "left", "right"]
        self.State = State()
        self.isEnd = self.State.isEnd

        # initial Q values
        self.Q_values = {}
        self.N={}
        for i in range(BOARD_ROWS):
            for j in range(BOARD_COLS):
                self.Q_values[(i, j)] = {}
                self.N[(i, j)] = {}
                for a in self.actions:
                    self.Q_values[(i, j)][a] = 0  # Q value is a dict of dict
                    self.N[(i, j)][a] = 0

    def chooseAction(self):
        mx_nxt_reward = 0
        action = ""

        if np.random.uniform(0, 1) <= EXPLORATION:
            action = np.random.choice(self.actions)
        else:
            for a in self.actions:
                current_position = self.State.state
                nxt_reward = self.Q_values[current_position][a]
                if nxt_reward >= mx_nxt_reward:
                    action = a
                    mx_nxt_reward = nxt_reward
        return action

    def takeAction(self, action):
        position = self.State.nxtPosition(action)
        return State(state=position)

    def reset(self):
        self.states = []
        self.State = State()
        self.isEnd = self.State.isEnd

    def play(self, rounds=10000):
        i = 0
        while i < rounds:
            # to the end of game back propagate reward
            if self.State.isEnd:
                reward = self.State.giveReward()
                for a in self.actions:
                    self.Q_values[self.State.state][a] = reward
                for s in reversed(self.states):
                    learning_rate=1/(self.N[s[0]][s[1]])
                    if(s[0]==SPECIAL_STATE):
                        reward_state=REWARD_SPECIAL_STATE
                    else:
                        reward_state=REWARD_NORMAL
                    current_q_value = self.Q_values[s[0]][s[1]]
                    reward = current_q_value + learning_rate * (reward_state + DISCOUNT_FACTOR * reward - current_q_value)
                    self.Q_values[s[0]][s[1]] = round(reward, 2)
                self.reset()
                i += 1
            else:
                action = self.chooseAction()
                self.states.append([(self.State.state), action])
                self.N[self.State.state][action]+=1
                self.State = self.takeAction(action)
                self.State.isEndFunc()
                self.isEnd = self.State.isEnd
        print(i)
        
                
    def showQvalues(self):
        for i in range(BOARD_ROWS):
            print('-----------------------------------------------------')
            out = '| '
            k=0
            for a in self.actions:
                k+=1
                for j in range(BOARD_COLS):
                    out += str(self.Q_values[(i, j)][a]).ljust(7)
                    if(a == 'up'):
                        out+=' ^ ' + ' | '
                    elif(a=='down'):
                        out+=' v ' + ' | '
                    elif(a=='left'):
                        out+=' < ' + ' | '
                    elif(a=='right'):
                        out+=' > ' + ' | '
                
                if(k!=4):
                    out+=' \n'
                    out+='| '
            print(out)
        print('-----------------------------------------------------')
    def showResults(self):
        #Utilities
        for i in range(BOARD_ROWS):
            print('-----------------------------------------')
            out = '| '
            for j in range(BOARD_COLS):
                max_utility=self.Q_values[(i, j)]["up"]
                for a in self.actions:
                    if self.Q_values[(i, j)][a] > max_utility:
                        max_utility =self.Q_values[(i, j)][a]
                out += str(max_utility).ljust(7) + ' | '
            print(out)
        print('-----------------------------------------')
        
        #Policies
        for i in range(BOARD_ROWS):
            print('---------------------')
            out = '| '
            for j in range(BOARD_COLS):
                if (i,j)==WIN_STATE:
                    out += '100| '
                elif (i,j)==FORBIDDEN_STATE:
                    out += ' F | '
                else:
                    max_utility=self.Q_values[(i, j)]["up"]
                    max_policy="up"
                    for a in self.actions:
                        if self.Q_values[(i, j)][a] > max_utility:
                            max_utility =self.Q_values[(i, j)][a]
                            max_policy=a
                            #print(max_policy)
                    if (max_policy=='up'):
                        out += ' ^ | '
                    elif (max_policy=='down'):
                        out += ' v | '
                    elif (max_policy=='left'):
                        out += ' < | '
                    elif (max_policy=='right'):
                        out += ' > | '
                    else:
                        out += ' err | '
            print(out)
        print('---------------------')

if __name__ == "__main__":
    ag = Agent()
    ag.play(20000)
    print(ag.showQvalues())
    print(ag.showResults())