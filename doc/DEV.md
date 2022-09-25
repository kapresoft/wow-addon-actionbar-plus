# Dev Resources

## CurseForge Support
- https://support.curseforge.com/en/support/solutions/folders/9000194118

## Debugging Tools
- https://www.reddit.com/r/WowUI/comments/2lpmff/help_what_debugging_tools_are_available_to/

### Slash commands

- /fstack: Shows a Z-ordered (I think) list of all the UI frames under the cursor

- /etrace: Shows a running commentary of game events (and the parameters passed to them) as they happen

- /dump: Just dumps a variable's value to chat. This works better than print for tables.

-  /script: Anything following this will executed immediately as Lua code.

### Replacement Tokens

#### Debug replacements

These occur based on filetype, as they tend to tie into the comment system for the file.
The insides aren't removed so that line numbers stay the same, they just cause them to be commented out.



#Lua

```text
--@debug@ and --@end-debug@
```

Turns into --[===[@debug and --@end-debug]===].


```text
--[===[@non-debug@ and --@end-non-debug@]===]
```

Turns into --@non-debug@ and --@end-non-debug@.


XML

```text
<!--@debug@--> (insert code here) <!--@end-debug@-->
```
Turns into <!--@debug (insert code here) @end-debug@-->.


```text
<!--@non-debug@ (insert code here) @end-non-debug@-->
```
Turns into <!--@non-debug@--> (insert code here) <!--@end-non-debug@-->.



### TOC

```text
#@debug@ and #@end-debug@>
```
Turns into #@debug@ and #@end-debug@, as well as adding a # to the beginning of each line in-between.

More at https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging#Replacement-Tokens

### Testing Release with BigWigMods/packager
```shell
 # pwd should be the top-level project
 $ ~/sandbox/github/wow/packager/release.sh
 # creates a .release directory
```