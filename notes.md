# Notes to improve the game

Use a reduced color palette for the game (PICO-8 or NES)

create a texture for defining color shading:
- all colors on first column and consecutive shading for each row
- each entity will use a gray scale texture encoding the row to use
- => one gray scale texture for each character of each team
- => gives a super cool retro lighting effect

https://hackernoon.com/pico-8-lighting-part-1-thin-dark-line-8ea15d21fed7


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