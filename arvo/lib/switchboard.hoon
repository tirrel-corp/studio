/-  *switchboard
/+  resource, graph-store
|%
++  moon
  |=  [our=ship who=ship]
  ^-  ?
  ?|  =(our who)
      &(?=(%earl (clan:title who)) =(our (^sein:title who)))
  ==
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  [%add-site (ot name+so host+so path+pa title+so ~)]
        [%edit-site (ot name+so host+so path+pa title+so ~)]
        [%del-site (ot name+so ~)]
        [%add-plugin (ot name+so path+pa plugin+plugin ~)]
        [%del-plugin (ot name+so path+pa ~)]
    ==
  ::
  ++  plugin
    ^-  $-(json ^plugin)
    %-  of
    :~  pipe+so
    ==
  ::
  --
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  u=^update
    ^-  json
    %+  frond  -.u
    ?-  -.u
        %add-site
      %-  pairs
      :~  name+s+name.u
          hostname+s+host.u
          path+s+(spat path.u)
          title+s+title.u
      ==
    ::
        %edit-site
      %-  pairs
      :~  name+s+name.u
          hostname+s+host.u
          path+s+(spat path.u)
          title+s+title.u
      ==
    ::
        %del-site
      %-  pairs
      :~  name+s+name.u
      ==
    ::
        %add-plugin
      %-  pairs
      :~  name+s+name.u
          path+s+(spat path.u)
          plugin+(pairs type+s+-.plugin.u name+s+name.plugin.u ~)
      ==
    ::
        %del-plugin
      %-  pairs
      :~  name+s+name.u
          path+s+(spat path.u)
      ==
    ::
        %full
      %-  pairs
      %+  turn  ~(tap by sites.u)
      |=  [host=@t =site]
      ^-  [@t json]
      [host (en-site site)]
    ==
  ::
  ++  en-site
    |=  s=site
    ^-  json
    %-  pairs
    :~  binding+(en-binding binding.s)
        title+s+name.s
        :-  %plugins
      %-  pairs
      %+  turn  ~(tap by plugins.s)
      |=  [=^path =plugin-state]
      ^-  [@t json]
      [(spat path) (en-plugin plugin-state)]
    ==
  ::
  ++  en-binding
    |=  =binding:eyre
    ^-  json
    %-  pairs
    :~  hostname+?~(site.binding ~ s+u.site.binding)
        path+s+(spat path.binding)
    ==
  ::
  ++  en-plugin
    |=  =plugin-state
    ^-  json
    %-  pairs
    :~  [%type %s -.plugin-state]
      :-  %name
      ?-  -.plugin-state
        %pipe    s+name.plugin-state
      ==
    ==
  ::
  --
--
