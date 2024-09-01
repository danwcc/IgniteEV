# IgniteEV
World of Warcraft mage addon
Cata Classic

type /ignite to see commands in-game 

Addon function: Fire Mages can press combustion to replicate periodic effects on their target.
This addon aims to maximize the damage value a player can get from this interaction via the Ignite DoT.
Ignite deals 40% of non-periodic spell critial hit damage as a 4 second DoT effect that stacks with more applications.
The addon pulls data from your character sheet and the cobat log in order to simulate ignite DoT damage if your next spell would crit.
If the ignite damage has a higher current value than the simulated future value, then it shows an icon on the screen to idicate that to the player.
This addon is my attempt to create a mathematical and procedural way to know when to press combustion. 
I made this because i like these kind of math problems.

I want to stop working on this addon and move on to other things, so feel free to make edits or implement this code into other projects.

500 lines of spaghetti code, so far known issues are:
1. Fights that include damage amps cause the addon to produce false information
2. The Pyrobast EV indicator buggs out at the start of fights sometimes. Only first 10 seconds of the pull have i seen any issues
3. Info Pannel is not adjustable with the /ignite unlock command. I did not see this as a priority.

Cheers!
