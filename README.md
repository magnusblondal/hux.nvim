# Hux: Notetaking into Obsidian inbox
Write notes from Neovim into a given folder.
## Lazy
```
return {
  {
      "magnusblondal/hux.nvim"
      path_to_obsidian = '$HOME/Documents/Obsidian/in'
    },
    keys = {
      { "<leader>h", mode = { "n" }, function() require("hux").note_from_buffer() end, desc = "Hux Obsidian note, whole buffer" },
      { "<leader>h", mode = { "v" }, function() require("hux").note_from_visual() end, desc = "Hux Obsidian note from selection" },
    }
  }
}
```
