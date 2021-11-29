/-  nam=naive-market
|%
::+$  init-info
::  $:  amount=cord
::      $=  billing
::      $:  first-name=cord
::          last-name=cord
::          address1=cord
::          address2=cord
::          city=cord
::          state=cord
::          postal=cord
::          phone=cord
::          email=cord
::      ==
::  ==
::
+$  error  [result-code=@ud result-text=@ta]
+$  finis
  $:  transaction-id=@ud
      authorization-code=@ud
      cvv-result=@tas
  ==
+$  transaction
  $%  [%success =info token=(unit @t) =finis]
      [%failure =info token=(unit @t) error=(unit error)]
      [%pending =info token=(unit @t)]
  ==
::
+$  request-to-token  (map request-id=cord token=cord)
+$  token-to-request  (map token=cord request-id=cord)
+$  request-to-time   (map request-id=cord time)
+$  transactions      ((mop time transaction) gth)
++  orm               ((on time transaction) gth)
+$  info  [who=ship sel=selector:nam currency=@ta total-price=cord]
::
+$  action
  $%  [%initiate-sale request-id=cord who=ship sel=selector:nam]
      [%complete-sale token-id=cord]
      [%set-api-key key=(unit cord)]
      [%set-site site=(unit [host=cord suffix=(unit term)])]
  ==
--

