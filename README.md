# Hux: Notetaking into Obsidian inbox
Write notes from Neovim into a given folder.

```
return {
  {
    dir = "~/code/nvim_plugins/hux.nvim",
    opts = {
      path_to_obsidian = '$HOME/Documents/Obsidian/in'
    },
    keys = {
      { "<leader>h", mode = { "n" }, function() require("hux").note_from_buffer() end, desc = "Hux Obsidian note, whole buffer" },
      { "<leader>h", mode = { "v" }, function() require("hux").note_from_visual() end, desc = "Hux Obsidian note from selection" },
    }
  }
}
```
