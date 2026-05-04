# s4t4n667_moneywash 
## Criminal moneywashing system 🧼💵

Highly customisable money laundering system, adding another dimension to criminal roleplay. You can add a blip to the map... keep it a secret... require an item to unlock the door or leave it open to whoever finds it! You also have the option to make the entry points move every time the script restarts.

## 🔐 Dependencies:
- [ESX](https://github.com/esx-framework/esx_core), [QBCore](https://github.com/qbcore-framework) or [Qbox](https://github.com/Qbox-project/)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
  
## 🔗 Useful links:
- [Preview video](https://youtu.be/3x8JiuAHwKI?si=V9zdU6uedD4t7BMc)
- [Documentation](https://s4t4n667.gitbook.io/asgaard-developments/free-scripts/s4t4n667_moneywash)

## ⚙️ How to install:
1) Download the latest release
2) Add `s4t4n667_moneywash` to your server's `resource` folder
3) Adjust the `config.lua` to your liking
4) Add the items into `ox_inventory/data/items.lua`
5) Restart your server
   
## 📦 Items:
```lua
    ['moneywash_key'] = { 
        label = 'Laundromat Key', 
        weight = 100, 
        stack = false, 
        description = 'This can be used to access the Laundromat.' 
    },

    ['moneywash_token'] = { 
        label = 'Laundromat Token', 
        weight = 10, 
        stack = true, 
        description = 'This can be used at the Laundromat to start a wash.' 
    },

    ['wet_bills'] = { 
        label = 'Wet Bills', 
        weight = 0, 
        stack = true, 
        description = 'Needs to be dried and bagged.' 
    },
```
Thank you to [StevoScripts](https://github.com/stevoscriptsteam) for allowing me to use code from an early release to build the backbone.

## 📌 Asgaard Developments
I’m a solo FiveM developer creating custom clothing, logos and graphics, liveries, MLO retextures and Discord servers. Lots of different packages available, along with plenty of free assets and scripts for the community to enjoy. 

Join the Discord: [here](https://discord.gg/eFsB5ZFxeq)
