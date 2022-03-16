|%
+$  services  (map @tas service)
+$  service
  $:  users=(map id user)
      access-duration=(unit @dr)
  ==
::
+$  id
  $@  @p
  [%email p=@tas]
::      [%phone p=@ud q=@p]
::
+$  user
  $:  access-code=(unit @q)
      expiry-date=(unit @da)
  ==
::
+$  update
  $%  [%add-service p=@tas q=service]
      [%del-service p=@tas]
      [%mod-access-duration p=@tas q=(unit @dr)]
      [%add-user p=@tas q=id r=user]
      [%del-user p=@tas q=id]
      [%ask-access p=@tas q=id]
  ==
--
