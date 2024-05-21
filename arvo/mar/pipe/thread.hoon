/+  resource
=>  |%
    +$  remove-inputs
      $:  site-name=term
          plugin-name=term
          sub-path=path
      ==
    ++  remove-dejs
      =,  dejs:format
      ^-  $-(json remove-inputs)
      %-  ot
      :~  site-name+so
          plugin-name+so
          sub-path+pa
      ==
    +$  edit-inputs
      $:  site-name=term
          old-sub-path=path
          new-sub-path=path
          old-plugin-name=term
          new-plugin-name=term
          =resource:resource
          template=term
          comments=?
          style=(unit term)
          headline=@t
          profile-img=@t
          header-img=@t
      ==
    ++  edit-dejs
      =,  dejs:format
      ^-  $-(json edit-inputs)
      %-  ot
      :~  site-name+so
          old-sub-path+pa
          new-sub-path+pa
          old-plugin-name+so
          new-plugin-name+so
          resource+dejs:resource
          template+so
          comments+bo
          style+(mu so)
          headline+so
          profile+so
          header+so
      ==
    ::
    +$  add-inputs
      $:  site-name=term
          plugin-name=term
          sub-path=path
          =resource:resource
          template=term
          comments=?
          style=(unit term)
          headline=@t
          profile-img=@t
          header-img=@t
      ==
    ++  add-dejs
      =,  dejs:format
      ^-  $-(json add-inputs)
      %-  ot
      :~  site-name+so
          plugin-name+so
          sub-path+pa
          resource+dejs:resource
          template+so
          comments+bo
          style+(mu so)
          headline+so
          profile+so
          header+so
      ==
    ::
    +$  thread-action
      $%  [%add add-inputs]
          [%edit edit-inputs]
          [%remove remove-inputs]
      ==
    ++  thread-dejs
      =,  dejs:format
      ^-  $-(json thread-action)
      %-  of
      :~  add+add-dejs
          edit+edit-dejs
          remove+remove-dejs
      ==
    --
|_  act=thread-action
++  grow
  |%
  ++  noun  act
  --
++  grab
  |%
  ++  noun  thread-action
  ++  json  thread-dejs
  --
++  grad  %noun
--
