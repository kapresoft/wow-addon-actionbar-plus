# Downloading the WoW Interface Code

It sounds like you're having trouble with the `ExportInterfaceFiles code` command on the TBC Classic PTR. The command is a bit finicky and only works under specific conditions.

Here is how to properly use the command to extract the interface files:

## 1. Enable the console in the Battle.net launcher

* Open the Blizzard Battle.net application.
* Go to **World of Warcraft** in your game list.
* Click **Options** (the cogwheel next to the Play button) and select **Game Settings**.
* Check the box for **Additional command line arguments** under the appropriate game version (**classic** or **classic_ptr**).
* In the text field that appears, type `-console`.
* Click **Done**.

## 2. Run the command in-game (at the correct screen)

* Launch the game via the Battle.net app.
* **Do not log into a character.** The command only works from the main **login screen or character selection screen**.
* Once you are at the character selection screen, press the grave/tilde key (`\`` / `~`) (usually located to the left of the **1** key) to open the console.
* In the console, type:

```
ExportInterfaceFiles code
```

and press **Enter**.

## 3. Interface Code Location

After executing the previous step, the `BlizzardInterfaceCode` folder is created at the install location.

Example (In Macs):  `/Applications/World of Warcraft/_classic_era_ptr_/BlizzardInterfaceCode`
