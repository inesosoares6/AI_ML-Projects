import numpy as np

BOARD_ROWS = 4
BOARD_COLS = 4
WIN_STATE = (3, 3)
SPECIAL_STATE = (2, 2)
FORBIDDEN_STATE=(3,2)
START = (3, 0)
DETERMINISTIC = False
P1=0.8
P2=0.1
P3=0.1
DISCOUNT_FACTOR=0.99
EXPLORATION = 0.05 #0.2


class State:
    def __init__(self, state=START):
        self.board = np.zeros([BOARD_ROWS, BOARD_COLS])
        self.board[3, 2] = -1
        self.state = state
        self.isEnd = False
        self.determine = DETERMINISTIC

    def giveReward(self):
        if self.state == WIN_STATE:
            return 100
        elif self.state == SPECIAL_STATE:
            return -20
        else:
            return -1

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
        """
        action: up, down, left, right
        -------------
        0 | 1 | 2| 3|
        1 |
        2 |
        return next position on board
        """
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
            # non-deterministic
            action = self._chooseActionProb(action)
            self.determine = True
            nxtState = self.nxtPosition(action)

        # if next state is legal
        if (nxtState[0] >= 0) and (nxtState[0] <= 2):
            if (nxtState[1] >= 0) and (nxtState[1] <= 3):
                if nxtState != (1, 1):
                    return nxtState
        return self.state

    def showBoard(self):
        self.board[self.state] = 1
        for i in range(0, BOARD_ROWS):
            print('-----------------')
            out = '| '
            for j in range(0, BOARD_COLS):
                if self.board[i, j] == 1:
                    token = '*'
                if self.board[i, j] == -1:
                    token = 'z'
                if self.board[i, j] == 0:
                    token = '0'
                out += token + ' | '
            print(out)
        print('-----------------')


class Agent:

    def __init__(self):
        self.states = []  # record position and action taken at the position
        self.actions = ["up", "down", "left", "right"]
        self.State = State()
        self.isEnd = self.State.isEnd
        self.lr = 0.2
        self.exp_rate = EXPLORATION
        self.decay_gamma = DISCOUNT_FACTOR

        # initial Q values
        self.Q_values = {}
        for i in range(BOARD_ROWS):
            for j in range(BOARD_COLS):
                self.Q_values[(i, j)] = {}
                for a in self.actions:
                    self.Q_values[(i, j)][a] = 0  # Q value is a dict of dict

    def chooseAction(self):
        # choose action with most expected value
        mx_nxt_reward = 0
        action = ""

        if np.random.uniform(0, 1) <= self.exp_rate:
            action = np.random.choice(self.actions)
        else:
            # greedy action
            for a in self.actions:
                current_position = self.State.state
                nxt_reward = self.Q_values[current_position][a]
                if nxt_reward >= mx_nxt_reward:
                    action = a
                    mx_nxt_reward = nxt_reward
            # print("current pos: {}, greedy aciton: {}".format(self.State.state, action))
        return action

    def takeAction(self, action):
        position = self.State.nxtPosition(action)
        # update State
        return State(state=position)

    def reset(self):
        self.states = []
        self.State = State()
        self.isEnd = self.State.isEnd

    def play(self, rounds=10):
        i = 0
        while i < rounds:
            # to the end of game back propagate reward
            if self.State.isEnd:
                # back propagate
                reward = self.State.giveReward()
                for a in self.actions:
                    self.Q_values[self.State.state][a] = reward
                #print("Game End Reward", reward)
                for s in reversed(self.states):
                    current_q_value = self.Q_values[s[0]][s[1]]
                    reward = current_q_value + self.lr * (self.decay_gamma * reward - current_q_value)
                    self.Q_values[s[0]][s[1]] = round(reward, 2)
                self.reset()
                i += 1
            else:
                action = self.chooseAction()
                # append trace
                self.states.append([(self.State.state), action])
                #print("current position {} action {}".format(self.State.state, action))
                # by taking the action, it reaches the next state
                self.State = self.takeAction(action)
                # mark is end
                self.State.isEndFunc()
                #print("nxt state", self.State.state)
                #print("---------------------")
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

if __name__ == "__main__":
    ag = Agent()
    ag.play(50)
    print(ag.Q_values)
    print(ag.showQvalues())