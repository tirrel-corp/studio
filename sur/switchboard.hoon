/-  pipe
|%
+$  versioned-state
  $%  [%0 state-0]
  ==
::
+$  state-0
  $:  sites=(map @t site)
  ==
::
+$  site
  $:  plugins=(map path plugin)
  ==
::
+$  plugin
  $%  [%pipe name=term =website:pipe]
      [%mailer name=term]
  ==
::
+$  action
  $%  [%add-site name=@t]
      [%del-site name=@t]
      [%add-plugin name=@t =path =plugin]
      [%del-plugin name=@t =path]
  ==
--
