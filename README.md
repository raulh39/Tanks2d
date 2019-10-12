# Tanks 2d

Learning to program in godot using the fantastic Tanks board game

# TODO
 - [ ] The window should be resizeable
 - [ ] When zoomed, some visual indication should appear in order to know where is the tank you need to move/shoot/command
 - [ ] Change mouse pointer to a hand when over a selectable object
 - [ ] Use static typing in all the code
 - [ ] Enable warnings and fix them
 - [x] MENU
   - [x] Landing page with start and quit
   - [x] Start should launch main scene
 - [x] MAIN SCENE
   - [x] Use coroutines to handle game phases
   - [x] Background
   - [x] Woods
   - [x] Buildings
   - [x] Tanks
   - [x] Collision layers
 - [ ] MOVEMENT PHASE
   - [x] Handle tanks initiative order
   - [x] Place arrow
   - [x] Reparent tank under arrow & Move tank along arrow
   - [x] Detect invalid tank posistions
   - [x] Capacity to end movement without moving or moving only one
   - [x] Place movement marker
   - [ ] Hability: Fast (3 movements)
   - [ ] When waiting to select tank, some visual message should appear
 - [ ] SHOOT PHASE
   - [x] Handle tanks initiative order
   - [x] Pick target
   - [ ] When waiting to select tank, some visual message should appear
   - [x] Move turret to face selected tank (maybe mouse?)
   - [ ] Line of sight
   - [ ] Firing arc
   - [ ] It should be possible not to fire
   - [ ] Make roll
     - [ ] Calculate number of attack dices
     - [ ] Calculate number of defense dices
   - [ ] Reroll if stationary
   - [ ] Cover
   - [ ] Close range
   - [ ] Side shot
   - [ ] Assault gun
   - [ ] Hability: Coordinated Fire
   - [ ] Hability: Gung Ho
   - [ ] Hability: Semi-Indirect Fire
 - [ ] COMMAND PHASE
   - [ ] Destroy Tanks
   - [ ] Check For Victory
   - [ ] Repair Damage / Hability: Blitzkrieg
   - [ ] Reset the field

