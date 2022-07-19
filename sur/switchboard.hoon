/-  pipe
|%
+$  versioned-state
  $+  versioned-state
  $%  [%0 state-0]
  ==
::
+$  state-0
  $+  state-0
  $:  sites=(map term site)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin [term path])
  ==
::
+$  site
  $+  site
  $:  =binding:eyre
      plugins=(map path plugin-state)
  ==
::
+$  plugin-state
  $+  plugin-state
  $%  [%pipe name=term =website:pipe]
      [%mailer name=term]
  ==
::
+$  plugin
  $+  plugin
  $%  [%pipe name=term]
      [%mailer name=term]
  ==
::
+$  action
  $+  action
  $%  [%add-site name=term host=@t =path]
      [%del-site name=term]
      [%add-plugin name=term =path =plugin]
      [%del-plugin name=term =path]
  ==
::
+$  update
  $+  update
  $~  [%full ~]
  $%  action
      [%full sites=(map @t site)]
  ==
--
