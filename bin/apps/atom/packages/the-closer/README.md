# The Closer package

Closes the window when or after the last tab is closed. Doesn't ask any questions.

## Configuration options

You can use the `the-closer.closeWindowTogetherWithLastTab` [configuration option](https://atom.io/docs/latest/customizing-atom#advanced-configuration) to configure whether the window is closed with or after the last tab is closed:

```coffee
# config.cson

'the-closer':
  'closeWindowTogetherWithLastTab': true
```

You can also configure this option in _Atom > Preferences > Close After Last Tab_.

If `closeWindowTogetherWithLastTab` is set to `false`, then the current window will be closed when `core:close` is triggered (e.g. with `cmd-w`) after the last tab has been closed. In other words, you need to press `cmd-w` again after the last tab has been closed.

If `closeWindowTogetherWithLastTab` is set to `true`, then the current window will be close when `core:close` is triggered to close the last tab. In other words, pressing `cmd-w` to close the last tab will also close the window.

By default, `closeWindowTogetherWithLastTab` is set to `true`.
