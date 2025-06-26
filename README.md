# AUR.FPE.RP
Archive User Repository maintain all users FPE:RP Repository for next future installation packages.

## Configurations / Settings 
Before you publishing your packages, please read this guides first.

**Default Settings** <br>
You need `package.lua` and `package-lock.lua` in your packages. <br>

Package.lua:
```lua
-- package.lua
return {
    name = "[NAME_OF_PACKAGE]",
    version = "1.0.0", -- rules, only start from 1.0.0
    description = "", -- opsional description
    author = "", -- require your roblox Username / Display name
    license = "", -- Choose your License
    repository = "https://github.com/UocDev/AUR.FPE.RP",
    dependencies = {},
    entry = "src/init", -- setup your default main entry point
    tags = {""},
}
```
package-lock.lua
```lua
-- package-lock.lua
return {
    name = "[NAME_OF_PACKAGE]",
    version = "1.0.0",
    lockVersion = 1,

    dependencies = {
        -- Example dependency
        -- ["uocdev/utility"] = {
        --     version = "1.2.3",
        --     resolved = "https://github.com/uocDev/...",
        --     integrity = "sha256-abc123...",
        -- }
    }
}
```
You can copy this if you don't have one <br>

**Directory** <br>
If you want publishing you own package, let's setup your own directory: <br>
We use scope name for directory `AUR.FPE.RP/package/[YOUR_NAME]/[SCOPE_PACKAGE_OR_ORIGIN]` <br>

Example:
`AUR.FPE.RP/package/Uoc/@uocTimestamp` or without @ `timestamp` <br>

**what files/dir you must setup** <br>
you need: <br>
• `package.lua` <br>
• `package-lock.lua` <br>
• `index.lua` enty point for export your modules <br>
• `LICENSE` for license you choose <br>
• `README.md` require if give more information <br>
• `lib` / `src` for function module scripts `../@YauiseTimestamp/src/*.lua` or `../@YauiseAPI/lib/*.lua` <br>

## Report into Uoc 
If you have bad conditions when push package with other developers or users, please contact me direct Discord DM or my Email Commits
