/-  pipe, *resource
|%
+$  versioned-state
  $+  versioned-state
  $%  [%0 state-0]
      [%1 state-1]
  ==
::
+$  state-1
  $+  state-1
  $:  sites=(map term site)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin [term path])
      join-rules=(map ship join-data)
  ==
::
+$  state-0
  $+  state-0
  $:  sites=(map term site)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin [term path])
  ==
::
+$  join-data
  $:  serfs=(set ship)
      =rule-set
  ==
::
+$  rule-set
  $:  %0
      groups=(set [resource private=?])
      pals=(set ship)
  ==
::
+$  rule
  $%  [%group =resource private=?]
      [%pals =ship]
  ==
::
+$  controller-action
  $%  [%group-add =resource who=ship]
      [%pal-add lord=ship who=ship]
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
      [%edit-site name=term host=@t =path]
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
