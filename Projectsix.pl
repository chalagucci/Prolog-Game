/*
This is a little adventure game. There are four entities: you, a treasure, a key, and an ogre. There are
seven places: a gate, a valley, a path, a cliff, a fork, a maze, and a mountaintop. Your goal is to get the treasure without being killed first.
*/

/*
First, text descriptions of all the places in the game.
*/ 
description(valley,
'You are in a pleasant valley, with a trail ahead.'). 
description(path,
'You are on a path, with ravines on both sides.'). 
description(cliff,
'You are teetering  on the edge of a cliff.').
description(fork,
'You are at a fork in the path.').
description(maze(_), 
'You are in a maze of twisty trails, all alike.').
description(mountaintop,
'You are on the mountaintop.').
description(gate, 
'You are in a narrow tunnel with an unlocked gate before you. ') :-
state(gate, unlocked).
description(gate, 
'You are in a narrow tunnel with a locked gate before you. ') :-
state(gate, locked).
description(key, 'a curiously shaped silver key').
description(treasure, 'a vast glittering treasure').
description(ogre, 'an ogre of menacing aspect').

/*
These connect predicates establish the map. The meaning of connect(X,Dir,Y) is that if you are at X and you move in direction Dir, you get to Y. Recognized directions are
forward, right, and left.
*/
connect(valley,forward,path). 
connect(path,backward,cliff). 
connect(path,right,cliff). 
connect(path,left,cliff). 
connect(path,forward,fork). 
connect(fork,backward,path). 
connect(fork,left,maze(0)).
connect(fork,right,gate).
connect(gate,backward,fork).
connect(maze(0),left,maze(1)). 
connect(maze(0),right,maze(3)). 
connect(maze(1),left,maze(0)). 
connect(maze(1),right,maze(2)). 
connect(maze(2),left,fork). 
connect(maze(2),right,maze(0)). 
connect(maze(3),left,maze(0)). 
connect(maze(3),right,maze(3)).

/*
connect(gate,forward,X) depends on the situtation.
From the unlocked gate you can go forward
to the mountaintop, but only if not holding the key.
*/
connect(gate,forward,mountaintop) :-
    state(gate, unlocked),
    not(at(key,you)),
    !.

/*
From the unlocked gate if you go forward holding the key, you die
*/
connect(gate,forward,done) :-
    state(gate,unlocked),
    at(key,you),
    write('The key in your pocket begins to burn with white fire.\n'),
    write('As you claw at your smoldering pants, lightning\n'),
    write('strikes you and you die.\n'),
    !.

/* 
If you try to wait through the locked gate you don't succeed.
*/
connect(gate,forward,gate) :-
     state(gate, locked),
     write('You walk into the gate, then stagger back, stunned.\n').

/* 
If the game is done, report does nothing
*/
report :-
   at(you,done),
   !.

/* 
Otherwise, report prints the description of your current location
*/
report :-
    at(you,Loc),
    description(Loc,Y),
    write(Y), 
    nl,
    printall('You have ',Thing,at(Thing,you)),
    printall('You see ',Thing,at(Thing,Loc)),
    nl.

/*
printall(Pre,Thing,Goal) prints the descriptions of zero or more things. Pre is 
the prefix to print with each line. Goal is the goal to call to find one thing;
Thing is a variable in that goal.
*/
printall(Pre,Thing,Goal) :-
    call(Goal),
    description(Thing,Desc),
    write(Pre),
    write(Desc),
    write('.\n),
    0=1. % The Prolog idiom is to use the predefined 'fail'
print(_,_,_).

/*
move(Dir) moves you in direction Dir, then prints the description of your new location.
*/
move(Dir) :-
at(you,Loc),
connect(Loc,Dir,Next), 
retract(at(you,Loc)), 
assert(at(you,Next)), 
report,
!. 

/*
But if the argument was not a legal direction,
print an error message and don't move. 
*/
move(_) :-
write('That is not a legal move.\n'), report.

/*
Shorthand for moves.
*/
forward :- move(forward). 
left :- move(left).
right :- move(right).

/*
pickup(X): if you and X are at the same location,
we move X to be at location "you".
*/
pickup(X) :-
    at(you,Loc),
    at(X,Loc),
    retract(at(X,Loc)),
    assert(at(X,you)),
    write('Got it.\n'),
    !.

/*
Otherwise, pickup(X) fails.
*/
pickup(X) :-
    write('There is no'),
    write(X),
    write(' here.\n').

/*
putdown(X): if you are holding X, drop it. It goes to your present location.
*/
putdown(X) :-
    at(X,you),
    at(you,Loc),
    retract(at(X,you)),
    assert(at(X,Loc)),
    write('Dropped it.\n'),
    !.

/*
Otherwise, putdown(X) fails.
*/
putdown(X) :-
    write('You have no '),
    write(X),
    write(' to drop.\n').

/*
If you use the key at the gate, the gate state flips between locked and unlocked.
Using the key anywhere else has no effect.
Using something you don't have gets a warning.
*/
use(key) :-
at(key,you),
at(you,gate),
state(gate,locked),
write('You use the key to unlock the gate.\n'),
retract(state(gate,locked)),
assert(state(gate,unlocked)),
!.
use(key) :-
at(key,you),
at(you,gate),
state(gate,unlocked),
write('You use the key to unlock the gate.\n'),
retract(state(gate,unlocked)),
assert(state(gate,locked)),
!.
use(key) :-
not(at(X,you)),
write('You wave the key in the air. Nothing happens.\n'),
!.
use(key) :-
not(at(you)),
write('You have no'),
write(X),
write(' to use.\n'),

/*
If you and the ogre are at the same place, it kills you.
*/
ogre :-
at(ogre,Loc), 
at(you,Loc),
write('An ogre sucks your brain out through\n'), 
write('your eye sockets, and you die.\n'), 
retract(at(you,Loc)),
assert(at(you,done)),
!.

/*
But if you and the ogre are not in the same place,
nothing happens. 
*/
ogre.

/*
If you and the treasure are at the same place, you win.
*/
treasure :-
at(treasure,Loc),
at(you,Loc),
write('There is a treasure here.\n'), 
write('Congratulations, you win!\n'), 
retract(at(you,Loc)), 
assert(at(you,done)),
!.

/*
But if you and the treasure are not in the same place, nothing happens.
*/ 
treasure.

/*
If you are at the cliff, you fall off and die.
*/
cliff :-
at(you,cliff),
write('You fall off and die.\n'), 
retract(at(you,cliff)), 
assert(at(you,done)),
!.

/*
But if you are not at the cliff nothing happens.
*/ 
cliff.

/*
Main loop. Stop if player won or lost.
*/
main :-
at(you,done),
write('Thanks for playing.\n'), 
!.

/*
Main loop. Not done, so get a move from the user and make it. Then run all our special behaviors. Then repeat.
*/
main :-
write('\nNext move -- '),
read(Move), 
call(Move), 
ogre, 
treasure, 
cliff, 
main.

/*
This is the starting point for the game. We assert the initial conditions, print an initial report, then start the main loop.
*/
go :-
retractall(at(_,_)), % clean up from previous runs 
retractall(state(_,_)),
assert(at(you,valley)),
assert(at(ogre,maze(3))), 
assert(at(treasure,mountaintop)),
assert(at(key,maze(2))),
assert(state(gate,locked)),
write('This is an adventure game. \n'),
write('Legal moves are left, right, or forward.\n'), 
write('End each move with a period.\n\n'),
report,
main.