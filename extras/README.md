# Lock dialog theme (optional)

XScreenSaver's unlock dialog, styled to match the dark Ubuntu look of the
screensaver. These are X resources, so they work with stock xscreensaver 6.

| File | Looks like |
|---|---|
| `lock-dialog-flat.Xresources` | Flat dark dialog. Works with stock xscreensaver. |
| `lock-dialog.Xresources` | Ubuntu-style card with a border. A few lines (`outsideColor`, `opacity`) only do something with a patched `xscreensaver-auth`; stock xscreensaver ignores them. |

Install one:

```sh
cp extras/lock-dialog-flat.Xresources ~/.Xresources   # or merge into yours
xrdb -merge ~/.Xresources
xscreensaver-command -restart
```

To have it applied at every login, start xscreensaver with
`sh -c "xrdb -merge $HOME/.Xresources; xscreensaver --no-splash"` in your
autostart entry.
