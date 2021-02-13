/*
	** WROCLAW UNIVERSITY OF SCIENCE AND TECHNOLOGY **

	   * Artificial Intelligence and Machine Learning - PROJECT3 :: WUMPUS WORLD
	   * Author: Ines De Oliveira Soares (256652) 
	
  This program implements a agent strategy for the wumpus world.
  It tries to avoid the dangerous (pits and wumpus), so when finds a breeze or stench,
  it turns around and tries to find another way to the gold. The safe spaces (spaces 
  without breeze or stench) are saved in a list (safeSpace([])). As so the visited 
  spaces are saved in a list (visitedSpace([])). When the agent finds safe spaces,
  the priority is to move to a non-visited space with the following priority: right
  space, then the upper space, then left and finally down. After it has visited all
  the safe places in the list, just moves forward to try to find new safe space. And
  if he steps in a space with stench or breeze when trying to find new spaces (if he
  already visited that dangerous space), he takes the risk and moves forward.

  I also created a variable called state which saves the state of the action of the
  agent in order to be easier to debug and to follow the code.

  Also demonstrates how to keep track of his own position and orientation.
  The agent assumes that the starting point is (1,1) and orientation "east".
*/

%%%% INITIALIZATION %%%%
 
% auxiliary initial action generating rule
act(Action, Knowledge) :-

	% To avoid looping on act/2.
	not(gameStarted),			%only does this when the game is starting
	assert(gameStarted),

	% Creating initial knowledge
	worldSize(X,Y),				%this is given
	assert(myWorldSize(X,Y)),		%stores the size of the world
	assert(myPosition(1, 1, east)),		%this we assume by default
	assert(myTrail([])),			%stores the agents trail
	assert(haveGold(0)),			%counts the number of golds grabed
	assert(safeSpace([])),			%list of safe spaces location in the board
	assert(visitedSpace([])),		%list of visited spaces location in the board
	assert(state(0)),			%variable of current state
	act(Action, Knowledge).

%%%%% STANDARD ACTION GENERATING RULES %%%%

% this is our agent's algorithm, the rules will be tried in order
act(Action, Knowledge) :- exit_if_home(Action, Knowledge).	% if at home with gold
act(Action, Knowledge) :- go_back_step(Action, Knowledge).	% if have gold elsewhere
act(Action, Knowledge) :- pick_up_gold(Action, Knowledge).	% if just found gold
act(Action, Knowledge) :- go_back_stench(Action, Knowledge).	% if stench go back
act(Action, Knowledge) :- go_back_breeze(Action, Knowledge).	% if breeze go back
act(Action, Knowledge) :- turn_if_wall(Action, Knowledge).	% if against the wall
act(Action, Knowledge) :- go_right(Action, Knowledge).		% if the right space is safe and not visited, go there
act(Action, Knowledge) :- go_up(Action, Knowledge).		% if the upper space is safe and not visited, go there
act(Action, Knowledge) :- go_left(Action, Knowledge).		% if the left space is safe and not visited, go there
act(Action, Knowledge) :- go_down(Action, Knowledge).		% if the down space is safe and not visited, go there
act(Action, Knowledge) :- else_move_on(Action, Knowledge).	% otherwise move forward

%%%% EXIT GAME %%%%
exit_if_home(Action, Knowledge) :-
	haveGold(NGolds), NGolds > 0,
	myPosition(1, 1, Orient),
	Action = exit,	% game completed
	Knowledge = [].	% irrelevant but required

%%%% TURN AROUND AND GO HOME %%%%
	% assuming the agent has just found gold:
	% 1. the last action was grab
	% 2. the previuos action was moveForward
	% 3. so the agent initiates a turnback and then return:
	%    (a) pop grab from the stack
	%    (b) replace it by an artificial turnRight we have never
	%        executed, but we will be reversing by turning left
	%    (c) execute a turnRight now which together will turn us back
	% 4. after that the agent is facing back and can execute actions in reverse
	% 5. because of grab the agent can be sure this rule is executed exactly once

% first 'false' turn
go_back_step(Action, Knowledge) :-
	state(State),
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail(Trail),
	Trail = [ [grab,X,Y,Orient] | Trail_Tail ],
	New_Trail = [ [turnRight,X,Y,Orient] | Trail_Tail ],
	Action = turnLeft,
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, Orient), myTrail(New_Trail), state(1)].

% backtrack a moveForward --> moveForward
go_back_step(Action, Knowledge) :-
	state(State),
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [Action,X,Y,Orient] | Trail_Tail ]),
	Action = moveForward,
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, Orient), myTrail(Trail_Tail), state(2)].

% backtrack a turn --> oppositeTurn (reverse)
go_back_step(Action, Knowledge) :- go_back_turn(Action, Knowledge).

go_back_turn(Action, Knowledge) :-
	state(State),
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [OldAct,X,Y,Orient] | Trail_Tail ]),
	((OldAct=turnLeft,Action=turnRight);(OldAct=turnRight,Action=turnLeft)),
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, Orient), myTrail(Trail_Tail), state(3)].

%%%% GOLD %%%%
pick_up_gold(Action, Knowledge) :-
	state(State),
	glitter,
	Action = grab,
	haveGold(NGolds),
	NewNGolds is NGolds + 1,
	myWorldSize(Max_X, Max_Y),
	myPosition(X, Y, Orient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NewNGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, Orient), myTrail(New_Trail), state(4)].

%%%% STENCH %%%%
% in the case that the agent already visited this square (so it is trying to explore unknown spaces), he takes the risk and moves forward
go_back_stench(Action, Knowledge) :-
	state(State), not(State=5), not(State=6), not(State=7), % making sure he is not turning around to go back
	stench,
	safeSpace(Slist),
	visitedSpace(Vlist),
	on([X,Y],Vlist), % verifies if the space was already visited
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=moveForward,
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X, New_Y, Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(49)].

% finds this dangerous space for the first time, so he starts to turn around (first turn to turn around)
go_back_stench(Action, Knowledge) :-
	state(State), not(State=7), not(State=5), not(State=6), % making sure the agent doesn't interrupt the action of turning around 
	stench,
	visitedSpace(Vlist),
	safeSpace(Slist),
	NVlist=[[X,Y] | Vlist], % update the list of visited spaces
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=turnLeft,
	myPosition(X, Y, Orient),
	shiftOrientLeft(Orient, NewOrient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(Slist), state(5)].

% second turn to turn around
go_back_stench(Action, Knowledge) :-
	state(State), State=5, % after one turn left, he has to turn left one more time
	stench,
	safeSpace(Slist),
	visitedSpace(Vlist),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=turnLeft,
	myPosition(X, Y, Orient),
	shiftOrientLeft(Orient, NewOrient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(6)].

% moving forward after turning around
go_back_stench(Action, Knowledge) :-
	state(State), State=6, % after two times turning left, he has to move forward
	stench,
	haveGold(NGolds),
	safeSpace(Slist),
	visitedSpace(Vlist),
	myWorldSize(Max_X,Max_Y),
	Action=moveForward,
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myTrail(New_Trail), myPosition(New_X, New_Y, Orient), visitedSpace(Vlist), safeSpace(Slist), state(7)].
 
%%%% BREEZE %%%%

% in the case that the agent already visited this square (so it is trying to explore unknow spaces), he takes the risk and moves forward
go_back_breeze(Action, Knowledge) :-
	state(State),not(State=8), not(State=9),not(State=10), % making sure he is not turning around to go back
	breeze,
	safeSpace(Slist),
	visitedSpace(Vlist),
	on([X,Y],Vlist), % verifies if the space was already visited
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=moveForward,
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X, New_Y, Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(48)].

% finds this dangerous space for the first time, so he starts to turn around (first turn to turn around)
go_back_breeze(Action, Knowledge) :-
	state(State), not(State=8), not(State=9),not(State=10), % making sure the agent doesn't interrupt the action of turning around 
	breeze,
	safeSpace(Slist),
	visitedSpace(Vlist),
	NVlist=[ [X,Y] | Vlist], % updates the list of visited spaces
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=turnLeft,
	myPosition(X, Y, Orient),
	shiftOrientLeft(Orient, NewOrient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(Slist), state(8)].

% second turn to turn around
go_back_breeze(Action, Knowledge) :-
	state(State), State=8, % after one turn left, he has to turn left one more time
	breeze,
	safeSpace(Slist),
	visitedSpace(Vlist),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	Action=turnLeft,
	myPosition(X, Y, Orient),
	shiftOrientLeft(Orient, NewOrient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(9)].

% moving forward after turning around
go_back_breeze(Action, Knowledge) :-
	state(State), State=9, % after two times turning left, he has to move forward
	breeze,
	haveGold(NGolds),
	safeSpace(Slist),
	visitedSpace(Vlist),
	myWorldSize(Max_X,Max_Y),
	Action=moveForward,
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myTrail(New_Trail), myPosition(New_X, New_Y, Orient), visitedSpace(Vlist), safeSpace(Slist), state(10)].

%%%% WALL %%%%
turn_if_wall(Action, Knowledge) :-
	state(State),
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	safeSpace(Slist),
	visitedSpace(Vlist),
	X=7,Y=7,Orient=east, % if he hits the top-right corner facing east, he turns right
	Action = turnRight,
	shiftOrientRight(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(46)].

turn_if_wall(Action, Knowledge) :-
	state(State),
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	safeSpace(Slist),
	visitedSpace(Vlist),
	X=7,Y=1,Orient=south, % if he hits the right-bottom corner facing south, he turns right
	Action = turnRight,
	shiftOrientRight(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(47)].

turn_if_wall(Action, Knowledge) :-
	state(State),
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	safeSpace(Slist),
	visitedSpace(Vlist),
	X=1,Y=7,Orient=north, % if he hits the top-left corner facing north, he turns right
	Action = turnRight,
	shiftOrientRight(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(48)].

turn_if_wall(Action, Knowledge) :-
	state(State),
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	safeSpace(Slist),
	visitedSpace(Vlist),
	X=1,Y=1,Orient=west, % if he hits the letf-bottom corner facing west, he turns right
	Action = turnRight,
	shiftOrientRight(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(49)].

turn_if_wall(Action, Knowledge) :-
	state(State),
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	safeSpace(Slist),
	visitedSpace(Vlist),
	Action = turnLeft, % in any other cases, when he hits a wall, he turns left
	shiftOrientLeft(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X, Y, NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(11)].

% bumped into the right wall
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Orient = east.
% bumped into the down wall
againstWall(X, Y, Orient, Max_X, Max_Y) :- Y = 1, Orient = south.
% bumped into the top wall
againstWall(X, Y, Orient, Max_X, Max_Y) :- Y = Max_Y, Orient = north.
% bumped into the left wall
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1, Orient = west.

%%%% MOVE RIGHT %%%%
%case my direction is already east
go_right(Action, Knowledge):-
	state(State), not(State=13), not(State=15), not(State=17), 	% making sure he is not executing other action to move to the right space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=Max_X), 							% making sure we are not already on the border
	NVlist=[[X,Y] | Vlist],						% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]), 		% update safe list with surrondings of current space
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),	
	on([X1,Y],NSlist4),						% if the right space is on the safe list
	not(on([X1,Y],NVlist)),						% if the agent wasn't there yet
	Orient=east,							% and he is already facing east
	forwardStep(X,Y,Orient,New_X,New_Y), 				% just have to move forward
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(12)].
%case my direction is north
go_right(Action, Knowledge):-
	state(State), not(State=12), not(State=15), not(State=17),	% making sure he is not executing other action to move to the right space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=Max_X), 							% making sure we are not already on the border
	NVlist=[ [X,Y] | Vlist], 					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X1,Y],NSlist4), 						% if the right space is on the safe list
	not(on([X1,Y],NVlist)), 					% if the agent wasn't there yet
	Orient=north, 							% and he is facing north
	shiftOrientRight(Orient,NewOrient),
	Action=turnRight, 						% he has to turn right before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(13)].
go_right(Action, Knowledge):-
	state(State), State=13, % making sure that the previous action was the first turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(14)].
%case my direction is south
go_right(Action, Knowledge):-
	state(State), not(State=13), not(State=12), not(State=17),	% making sure he is not executing other action to move to the right space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X1,Y],NSlist4), 						% if the right space is on the safe list
	not(on([X1,Y],NVlist)), 					% if the agent wasn't there yet
	Orient=south, 							% and he is facing south
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(15)].
go_right(Action, Knowledge):-
	state(State), State=15, % making sure that the previous action was the first turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(16)].
%case my direction is west
go_right(Action, Knowledge):-
	state(State), not(State=13), not(State=15), not(State=12), 	% making sure he is not executing other action to move to the right space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist], 					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X1,Y],NSlist4),						% if the right space is on the safe list
	not(on([X1,Y],NVlist)), 					% if the agent wasn't there yet
	Orient=west, 							% and he is facing west
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left twice before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(17)].
go_right(Action, Knowledge):-
	state(State), State=17,	% making sure that the previous action was the first turn left and now he will execute the second one
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(18)].
go_right(Action, Knowledge):-
	state(State), State=18, % making sure that the previous action was the second turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(19)].

%%%% MOVE UP %%%%
%case my direction is already north
go_up(Action, Knowledge):-
	state(State),  not(State=21), not(State=23), not(State=25),  	% making sure he is not executing other action to move to the upper space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y1],NSlist4),						% if the upper space is on the safe list
	not(on([X,Y1],NVlist)),						% if the agent wasn't there yet
	Orient=north, 							% and he is already facing north
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,						% he just moves forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(20)].
%case my direction is west
go_up(Action, Knowledge):-
	state(State), not(State=20), not(State=23), not(State=25),  	% making sure he is not executing other action to move to the upper space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y1],NSlist4),						% if the upper space is on the safe list
	not(on([X,Y1],NVlist)),						% if the agent wasn't there yet
	Orient=west,							% and he is facing west
	shiftOrientRight(Orient,NewOrient),
	Action=turnRight,						% he has to turn right before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(21)].
go_up(Action, Knowledge):-
	state(State), State=21, % making sure that the previous action was turn right and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(22)].
%case my direction is east
go_up(Action, Knowledge):-
	state(State), not(State=21), not(State=20), not(State=25),  	% making sure he is not executing other action to move to the upper space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y1],NSlist4),						% if the upper space is on the safe list
	not(on([X,Y1],NVlist)),						% if the agent wasn't there yet
	Orient=east,							% and he is facing east
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(23)].
go_up(Action, Knowledge):-
	state(State), State=23, % making sure that the previous action was turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(24)].
%case my direction is south
go_up(Action, Knowledge):-
	state(State), not(State=21), not(State=23), not(State=20),  	% making sure he is not executing other action to move to the upper space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=Max_X), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y1],NSlist4),						% if the upper space is on the safe list
	not(on([X,Y1],NVlist)),						% if the agent wasn't there yet
	Orient=south,							% and he is facing south
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left twice before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(25)].
go_up(Action, Knowledge):-
	state(State), State=25, % making sure that the previous action was the first turn left and now he will turn left again
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(26)].
go_up(Action, Knowledge):-
	state(State), State=26, % making sure that the previous action was the second turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(27)].

%%%% MOVE LEFT %%%%
%case my direction is already west
go_left(Action, Knowledge):-
	state(State),  not(State=29), not(State=31), not(State=33),  	% making sure he is not executing other action to move to the left space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X0,Y],NSlist4),						% if the left space is on the safe list
	not(on([X0,Y],NVlist)),						% if the agent wasn't there yet
	Orient=west,							% and he is already facing west
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,						% he just moves forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(28)].
%case my direction is south
go_left(Action, Knowledge):-
	state(State), not(State=28), not(State=31), not(State=33),  	% making sure he is not executing other action to move to the left space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X0,Y],NSlist4),						% if the left space is on the safe list
	not(on([X0,Y],NVlist)),						% if the agent wasn't there yet
	Orient=south,							% and he is facing south
	shiftOrientRight(Orient,NewOrient),
	Action=turnRight,						% he has to turn right before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(29)].
go_left(Action, Knowledge):-
	state(State), State=29, % making sure that the previous action was turn right and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(30)].
%case my direction is north
go_left(Action, Knowledge):-
	state(State), not(State=29), not(State=28), not(State=33),  	% making sure he is not executing other action to move to the left space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X0,Y],NSlist4),						% if the left space is on the safe list
	not(on([X0,Y],NVlist)),						% if the agent wasn't there yet
	Orient=north,							% and he is facing north
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(31)].
go_left(Action, Knowledge):-
	state(State), State=31, % making sure that the previous action was turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(32)].
%case my direction is west
go_left(Action, Knowledge):-
	state(State), not(State=29), not(State=31), not(State=28),  	% making sure he is not executing other action to move to the left space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(X=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X0,Y],NSlist4),						% if the left space is on the safe list
	not(on([X0,Y],NVlist)),						% if the agent wasn't there yet
	Orient=west,							% and he is facing west
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left twice before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(33)].
go_left(Action, Knowledge):-
	state(State), State=33, % making sure that the previous action was the first turn left and now he will turn left one more time
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(34)].
go_left(Action, Knowledge):-
	state(State), State=34, % making sure that the previous action was the second turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(35)].

%%%% MOVE DOWN %%%%
%case my direction is already south
go_down(Action, Knowledge):-
	state(State),  not(State=37), not(State=39), not(State=41),  	% making sure he is not executing other action to move to the down space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y0],NSlist4),						% if the down space is on the safe list
	not(on([X,Y0],NVlist)),						% if the agent wasn't there yet
	Orient=south,							% and he is already facing south
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,						% he just moves forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(36)].
%case my direction is east
go_down(Action, Knowledge):-
	state(State),not(State=36), not(State=39), not(State=41),  	% making sure he is not executing other action to move to the down space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y0],NSlist4),						% if the down space is on the safe list
	not(on([X,Y0],NVlist)),						% if the agent wasn't there yet
	Orient=east,							% and he is facing east
	shiftOrientRight(Orient,NewOrient),
	Action=turnRight,						% he has to turn right before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(37)].
go_down(Action, Knowledge):-
	state(State), State=37, % making sure that the previous action was turn right and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(38)].
%case my direction is west
go_down(Action, Knowledge):-
	state(State),not(State=37), not(State=36), not(State=41),  	% making sure he is not executing other action to move to the down space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	on([X,Y0],NSlist4),						% if the down space is on the safe list
	not(on([X,Y0],NVlist)),						% if the agent wasn't there yet
	Orient=west,							% and he is facing west
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(39)].
go_down(Action, Knowledge):-
	state(State), State=39, % making sure that the previous action was turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(40)].
%case my direction is north
go_down(Action, Knowledge):-
	state(State),not(State=37), not(State=39), not(State=36),  	% making sure he is not executing other action to move to the down space
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	not(Y=1), 							% making sure we are not already on the border
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current location
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),	
	on([X,Y0],NSlist4),						% if the down space is on the safe list
	not(on([X,Y0],NVlist)),						% if the agent wasn't there yet
	Orient=north,							% and he is facing north
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,						% he has to turn left twice before moving forward
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(41)].
go_down(Action, Knowledge):-
	state(State), State=41, % making sure that the previous action was the first turn left and now he will turn left one more time
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	shiftOrientLeft(Orient,NewOrient),
	Action=turnLeft,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(X,Y,NewOrient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(42)].
go_down(Action, Knowledge):-
	state(State), State=42, % making sure that the previous action was the second turn left and now he will move forward
	myPosition(X,Y,Orient),
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	visitedSpace(Vlist),
	safeSpace(Slist),
	forwardStep(X,Y,Orient,New_X,New_Y),
	Action=moveForward,
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge=[gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X,New_Y,Orient), myTrail(New_Trail), visitedSpace(Vlist), safeSpace(Slist), state(43)].

% function to search in a list
on(Item,[Item|Rest]).
on(Item,[DisregardHead|Tail]):-
	on(Item,Tail).

% shift orientation to turn right
shiftOrientRight(east, south).
shiftOrientRight(north, east).
shiftOrientRight(west, north).
shiftOrientRight(south, west).

% shift orientation to turn left
shiftOrientLeft(east, north).
shiftOrientLeft(north, west).
shiftOrientLeft(west, south).
shiftOrientLeft(south, east).

%%%% MOVE ON %%%%
else_move_on(Action, Knowledge) :-
	state(State),
	Action = moveForward,
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	visitedSpace(Vlist),
	safeSpace(Slist),
	X0 is X-1,X1 is X+1,Y0 is Y-1,Y1 is Y+1,
	NVlist= [ [X,Y] | Vlist],					% update visited list with the current location
	(X=1 -> NSlist1=Slist; NSlist1=[[X0,Y] | Slist]),		% update safe list with surrondings of current location
	(X=Max_X -> NSlist2=NSlist1; NSlist2=[[X1,Y] | NSlist1]),
	(Y=1 -> NSlist3=NSlist2; NSlist3=[[X,Y0] | NSlist2]),
	(Y=Max_Y -> NSlist4=NSlist3; NSlist4=[[X,Y1] | NSlist3]),
	Knowledge = [gameStarted, haveGold(NGolds), myWorldSize(Max_X, Max_Y), myPosition(New_X, New_Y, Orient), myTrail(New_Trail), visitedSpace(NVlist), safeSpace(NSlist4), state(47)].

% shift X or Y accordingly with the direction
forwardStep(X, Y, east,  New_X, Y) :- New_X is (X+1).
forwardStep(X, Y, south, X, New_Y) :- New_Y is (Y-1).
forwardStep(X, Y, west,  New_X, Y) :- New_X is (X-1).
forwardStep(X, Y, north, X, New_Y) :- New_Y is (Y+1).

