
# LOT Wizardry summary

For pandan's eyes only

## Skill System

TODO

## Fatigue

Fatigue works.

## Item Effect Rework

Item Effect Rework, as the name implies, reworks the way item effects are handled. Basically instead of them being hardcoded by item id, this makes it so they are tied to the otherwise basically unused "item use" byte in the item's info.

Here is a list of item effect ids that are implemented:

|  id  | effect
| ---- | ------
| `00` | no effect
| `01` | heal staff effect
| `02` | mend staff effect
| `03` | recover staff effect
| `04` | physic staff effect
| `05` | fortify staff effect
| `06` | restore staff effect
| TODO |
