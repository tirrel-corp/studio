/-  pipe, *resource
|%
+$  versioned-state
  $+  versioned-state
  $%  [%0 state-0]
      [%1 *]
      [%2 state-2]
      [%3 state-3]
      [%4 state-4]
  ==
::
+$  state-4
  $+  state-4
  $:  sites=(map term site)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin [term path])
      join-rules=(map ship join-data)
      bg-image=(unit @t)
  ==
::
+$  state-3
  $+  state-3
  $:  sites=(map term site-3)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin-3 [term path])
      join-rules=(map ship join-data)
      bg-image=(unit @t)
  ==
::
+$  state-2
  $+  state-2
  $:  sites=(map term site-2)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin-3 [term path])
      join-rules=(map ship join-data)
      bg-image=(unit @t)
  ==
::
+$  state-1
  $+  state-1
  $:  sites=(map term site-2)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin-3 [term path])
      join-rules=(map ship join-data-1)
  ==
::
+$  state-0
  $+  state-0
  $:  sites=(map term site-2)
      by-binding=(map binding:eyre term)
      by-plugin=(map plugin-3 [term path])
  ==
::
+$  join-data
  $:  serfs=(set ship)
      =rule-set
  ==
::
+$  join-data-1
  $:  serfs=(set ship)
      rule-set=rule-set-0
  ==
::
+$  rule-set
  $:  %1
      groups=(set [resource private=?])
      pals=(set ship)
      bg-image=(unit @t)
  ==
::
+$  rule-set-0
  $:  %0
      groups=(set [resource private=?])
      pals=(set ship)
  ==
::
+$  rule
  $%  [%group =resource private=?]
      [%pals =ship]
      [%bg-image img=@t]
  ==
::
+$  controller-action
  $%  [%group-add =resource who=ship]
      [%pal-add lord=ship who=ship]
      [%bg-image img=@t]
  ==
::
+$  site
  $+  site
  $:  name=@t
      =binding:eyre
      plugins=(map path plugin-state)
  ==
::
+$  site-3
  $+  site-3
  $:  =binding:eyre
      plugins=(map path plugin-state-3)
  ==
::
+$  site-2
  $+  site-2
  $:  =binding:eyre
      plugins=(map path plugin-state-2)
  ==
::
+$  plugin-state
  $+  plugin-state
  $%  [%pipe name=term =website:pipe]
  ==
::
+$  plugin-state-3
  $+  plugin-state-3
  $%  [%pipe name=term =website:pipe]
      [%mailer name=term]
  ==
::
+$  plugin-state-2
  $+  plugin-state-2
  $%  [%pipe name=term website=*]
      [%mailer name=term]
  ==
::
+$  plugin
  $+  plugin
  $%  [%pipe name=term]
  ==
::
+$  plugin-3
  $+  plugin-3
  $%  [%pipe name=term]
      [%mailer name=term]
  ==
::
+$  action
  $+  action
  $%  [%add-site name=term host=@t =path title=@t]
      [%edit-site name=term host=@t =path title=@t]
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
