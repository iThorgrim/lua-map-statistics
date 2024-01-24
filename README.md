# Map Statistics

This module provides developers with a convenient way to add or modify player statistics based on specific conditions. These conditions include map, area, difficulty, class, and specialization.

## Table of Contents
- General Info
- Files
- Installation
- Features
- Class and API Definition
- Tasks
- Contributing

### General Info
The key aspect of this module is the flexibility it provides when managing player statistics, allowing developers to change attributes based on varying factors such as the player's area, map, class, map difficulty and specialization.

These attribute values are managed via databases, with this package providing general interfaces and functionalities for Create, Read operations. Additionally, a helper module is included to facilitate these functionalities and map attribute enumerations for more efficient access and queries.

### Files
This package consists primarily of three files :

1. map_stat\_helper.lua: This file contains enumerations and create/read queries for various attributes such as maps, statistics, and indices.
2. map_stat\_entity.lua: This file provides basic database operations, such as creating and retrieving both databases and tables, as well as associating maps with statistics. A variety of getter functions are included for different game classifications, along with methods to format these indices.
3. map_stat\_controller.lua: This file is tasked with handling state changes for players, as well as modifying player statistics. It provides functions for updating player statistics in response to certain game events.

### Installation
You can use git to clone this repository to your lua_scripts folder. 

Use the following commands:
```txt
git clone https://github.com/vaiocti/mod_map_statistic.git
```

### Features
- Ability to handle different classes, specializations, and stats.
- Individual getter functions for map, area, map difficulty, class, and specialization.
- Capability to request a database reload.
- Methods for real-time updating of player's stats during gameplay.

### Class and API Definition
Please refer to the code files for detailed information on supported APIs. 
Here's a general outline for reference:

- Entity: Base instance to store configurations. Can be recalled or constructed using New().
- Entity:GetForMap(map): Retrieve map information for a given map.
- Entity:GetForArea(area): Retrieve area information for a given area.
- Entity:GetForDifficulty(difficulty): Retrieve difficulty information for a given difficulty level.
- Entity:GetForClass(class): Retrieve class information for a given class.
- Entity:GetForSpecialization(spec): Retrieve specialization information for a given specialization.
- Entity:GetResult(): Get the final search results.

### Tasks
Accomplished:

- Designed and implemented three major modules: map\_stat\_helper.lua, map\_stat\_entity.lua and map\_stat\_controller.lua.
- Developed database queries for creating and reading indices, stats, and maps, along with the functionality of these operations.
- Constructed getter functions for map, area, difficulty, class, and specialization.
- Implemented a mechanism to handle real-time stat changes, such as updating player's stats during the game.

Upcoming (pseudo "no-code in table"):
- Finalize the remaining database schema which includes tables named index\_map\_stat\_actions, index\_map\_stat\_conditions and index\_map\_stat\_actions\_conditions\_associations.
- Populate the mentioned tables with relevant data.
- Design and implement functions/actions that will be linked with the action attribute from the index\_map\_stat\_actions table.
- Design and implement the condition handlers, logic operators and comparison operators that will use the operand, value, operator and logic\_operator attributes from the index\_map\_stat\_conditions table.
- Link the actions and conditions through index\_map\_stat\_actions\_conditions\_associations table.

```sql
-- An example of what's upcoming
CREATE TABLE `index_map_stat_conditions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `parent_id` int(10) DEFAULT NULL,
  `operand` enum('Group members','Map Player Size') NOT NULL,
  `value` int(10) NOT NULL,
  `operator` enum('>=','<=','==','~=','>','<') NOT NULL,
  `logic_operator` enum('AND','OR') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

insert  into `index_map_stat_conditions`(`id`,`parent_id`,`operand`,`value`,`operator`,`logic_operator`) values 
(1, NULL, 'Group members', 3, '<', NULL);
```

### Contributing
This repository welcomes contributors! Please adhere to the given coding style and conventions.
Make sure to properly describe your changes in your pull request comments.
