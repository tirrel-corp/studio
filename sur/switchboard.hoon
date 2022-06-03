/-  pipe
|%
+$  versioned-state
  $%  [%0 state-0]
  ==
::
+$  state-0
  $:  sites=(map @t site)
      by-plugin=(map plugin [@t path])
  ==
::
+$  site
  $:  plugins=(map path plugin-state)
  ==
::
+$  plugin-state
  $%  [%pipe name=term =website:pipe]
      [%mailer name=term]
  ==
::
+$  plugin
  $%  [%pipe name=term]
      [%mailer name=term]
  ==
::
+$  action
  $%  [%add-site name=@t]
      [%del-site name=@t]
      [%add-plugin name=@t =path =plugin]
      [%del-plugin name=@t =path]
  ==
::
+$  update
  $~  [%full ~]
  $%  action
      [%full sites=(map @t site)]
  ==
--
