# Notes to improve the game

Use a reduced color palette for the game (PICO-8 or NES)

create a texture for defining color shading:
- all colors on first column and consecutive shading for each row
- each entity will use a gray scale texture encoding the row to use
- => one gray scale texture for each character of each team
- => gives a super cool retro lighting effect

https://hackernoon.com/pico-8-lighting-part-1-thin-dark-line-8ea15d21fed7


select a color palette on this website:
https://lospec.com/palette-list


## Classes

Name      | Specie    | Primary        | Secondary      | Both            | Air          |
----------|-----------|----------------|----------------|-----------------|--------------|
Knight    | human     | sword          | shield         | charge          | X            |
Rogue     | elf       | bow            | grappling hook | X               | double jump  |
Wizard    | istari    | lightning bolt | magic ball     | X               | downthrust   |
Dragonewt | dragonewt | fire sparks    | fire blast     | X               | hovering     |
Nun       | witch     | rifle          | scope          | piercing shot   | head jump    |
Beast     | orc       | punch left     | punch right    | german suplex   | ground smash |
Glutton   | ogre      | bite           | puke           | X               | slide        |
Dwarf     | dwarf     | axe            | underground    | surprise attack | X            |
Summoner  | dark elf  | spirit ball    | skeleton       | X               | teleport     |
Bard      | satire    | ???            | ???            | ???             | wall jump    |
Trickster | hobbit    | ???            | ???            | ???             | ???          |


batch:
(1) knight, rogue, wizard, dragonewt
(2) nun, beast, glutton
(3) dwarf, summoner
(4) bard, trickster



## Menu system

### main menu
- find a game
- host a game
- edit user profile
- options
- quit


### find server
(for now just an IP address field, with a connect button and a back button)
filters
list of servers
display server informations before connecting

### host game
(for now list of maps select only one map and play)
list of game modes
list of maps
play list
server configuration
...

### user profile
select player name

### options
- video    (resolution, fullscreen)
- audio    (master, music, effects)
- controls (mouse sensibility, keyboard inputs)

