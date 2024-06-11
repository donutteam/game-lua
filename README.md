# Game.lua and related utils
A library for mods for The Simpsons: Hit &amp; Run that enable developers to easily use Lua to dynamically generate MFK and CON scripts.

## Game.lua
`Game.lua` is the main script that loads all the commands into the `Game` table.
### Usage
* Copy `Game.lua` to your mod's Resources folder, and load it in `CustomFiles.lua`.
  * Example: `dofile(GetModPath() .. "/Resources/lib/Game.lua)`.
* Add a `[PathHandlers]` entry to `CustomFiles.ini` for the required MFK and CON files.
  * Optional: Use the `Redirect.lua` specified below for ease of use.
  * Example: `scripts\\mission\\level01\\m0i.mfk=Resources/scripts/missions/level01/m0i.lua`.
* In the Lua script, write the script in more or less the same with with some notable differences:
  * All commands must be prefixed with `Game.`, since the script stores them in a table called `Game`
    * This is done for organizational reasons, as flooding the global table with all the functions would be messy.
  * You don't need to have `;` after function calls because Lua doesn't require them (though it doesn't hurt to have them).
  * Unlike MFK/CON, strings must *always* be in quotes.
    * This is notable because Radical omits quotes in a few places as the basic scripting didn't require it.
  * Backslashes `\` must be escaped with another backslash, like `\\`.
  * Writing conditional command blocks works differently. See the [Conditionals](#Conditionals) section below for more details.

### Examples
Here's some example comparisons of one of Radical's function calls and how it would look in Lua:

***MFK:***
```
LoadP3DFile("art\missions\level01\m0.p3d");

// Radical often didn't use quotes on their locator names for this command.
GagSetTrigger("action", JasperTrig, 2);
```
***Lua:***
```lua
Game.LoadP3DFile("art\\missions\\level01\\m0.p3d");

-- So you would need to add them for Lua.
Game.GagSetTrigger("action", "JasperTrig", 2);
```
Expanding on the above example path handler:

***CustomFiles.ini***
```ini
[PathHandlers]
scripts\\missions\\level01\\m0i.mfk=Resources/scripts/missions/level01/m0i.lua
```
***m0i.lua***
```lua
Game.SelectMission("m0")
    Game.SetMissionResetPlayerInCar("level1_carstart")
    Game.SetDynaLoadData("l1z1.p3d;l1r1.p3d;l1r7.p3d;")

    Game.UsePedGroup(0) 

    Game.AddStage(1)
        Game.RESET_TO_HERE()

        Game.SetHUDIcon("kwike")
        Game.SetStageMessageIndex(131)

        Game.AddObjective("dummy")
        Game.CloseObjective()
    Game.CloseStage()
Game.CloseMission()
```
### Conditionals
Additional Script Functionality adds conditional commands, such as `IfCurrentCheckpoint`. These commands are expected to be followed by a conditional block opened with `{` and closed with `}`.

Since there is no way to represent this in that manner in Lua, `Game.lua` handles outputting the opening `{`, and you must close it with `Game.EndIf()` - which just outputs `}`.

Additionally, to do an inverse conditional in MFK/CON, you can prefix the command with `!`, e.g. `!IfCurrentCheckpoint` would execute the conditional block only if it *wasn't* the current checkpoint. `Game.lua` handles this by adding `Not_` prefixed commands, as shown below.

***MFK:***
```
IfCurrentCheckpoint()
{
    SetStageTime(20);
}

!IfCurrentCheckpoint()
{
    SetStageTime(50);
}
```
***Lua:***
```lua
Game.IfCurrentCheckpoint()
    Game.SetStageTime(20)
Game.EndIf()

Game.Not_IfCurrentCheckpoint()
    Game.SetStageTime(50)
Game.EndIf()
```
*Note: Older versions of `Game.lua` added a `Game.Not()` function to support this functionality. This is still available for backwards compatibility, but isn't recommended.*
### Technical Details
The script contains a 3 local functions:
* `AddCommand` - This function takes 2 parameters: a `Command` table containing `Name`, `MinArgs`, `MaxArgs` and `Conditional` values; and a `Hack` string, which is the hack that the command requires.
  * When called, this function adds another function with the name of the command to the `Game` table, which has checks that the provided arguments are within the min/max values.
  * Additionally, if the given command is a conditional, it adds the inverse `Not_` version to the `Game` table also, that outputs a `!` before execution.
  * Finally, it uses the `Hack` string to increment a counter of how many commands for each hack are loaded.
* `AddInvalidCommand` - This function takes the same parameters as `AddCommand`.
  * When called, this function also adds another function with the name of the command to the `Game` table, however it will only throw a Lua error stating that the required hack isn't loaded.
  * Additionally, this also creates the inverse function if the command is a conditional.
  * Finally, it also increases the command count.
* `LoadHackCommands` - This function takes 2 parameters: a `Commands` table containing an array of the aforementioned `Command` tables; and an optional `Hack` string which is the hacks that the commands require, if omitted its default value is `Default`.
  * When called, this function checks if either the `Hack` parameter is omitted, or the specified hack is loaded.
  * Based on this check, it then either calls `AddCommand` or `AddInvalidCommand` on each `Command` in the `Commands` table.
  * Finally, it prints the number of commands loaded, as well as the time taken to the console.

The script also contains 3 `Command` tables:
* `DefaultCommands` - This contains all the commands that SHAR contains on its own.
* `ASFCommands` - This contains all the commands that Additional Script Functionality contains.
* `DebugTestCommands` - This contains all the commands that Debug Test contains.

## GameUtils.lua
`GameUtils.lua` is an optional script that adds helper utility functions to a `GameUtils` table, for example one function for every objective and condition.
### Usage
* Copy `GameUtils.lua` to your mod's Resources folder, and load it in `CustomFiles.lua` *after `Game.lua`*.
  * Example: `dofile(GetModPath() .. "/Resources/lib/GameUtils.lua)`.
* In a MFK or CON Lua script, you can now use `GameUtils` functions in place of their `Game` functions. For a full list, see the [Functions](#Functions) section below.

### Functions
#### TODO
