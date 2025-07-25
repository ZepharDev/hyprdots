<h1 align="center">Advertence</h1>

This is my personal configuration, so that's why you see LibreWolf in keybinds and myprograms. For example, $browser = librewolf. If you want to use Firefox instead, you'll have to manually modify the file. However, if you give me some time to further develop the script, I could make that easier.

Still, the absolute path where you can set Firefox (or any browser you want) is:
~/.config/hypr/core/myprograms.conf

You can access it in several ways, like the one shown below. You can edit it with nvim (I hope you do), or with nano. 

```bash
nvim ~/.config/hypr/core/myprograms.conf
```

If you've already applied the configurations, you can access it via zsh using nn. You would just need to change:
$browser = librewolf
to:
$browser = firefox
(Just to clarify, you can use any browser you prefer.)

I'm improving the configurations—menu updates are coming soon, so please be patient...

<h1 align="center">windowrulev2</h1>

Window rules are applied in the way that feels right, if there is a window that you would like to add rules to, the command

```bash
windowrulev2 = float, class:^(dolphin)$
```

Here, for example, we define the application or window named "dolphin" to float in the center of the screen. You can find more information in the official hyprland documentation or the wiki.