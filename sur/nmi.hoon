/-  nam=shop
|%
+$  error  [result-code=@ud result-text=@ta]
+$  finis
  $:  transaction-id=@ud
      authorization-code=@ud
      cvv-result=@tas
      email=@t
      cc-num=@t
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
      [%set-backend-url site=(unit [host=cord suffix=(unit term)])]
      [%set-redirect-url p=(unit @t)]
  ==
::  old structures
+$  transactions-0  ((mop time transaction-0) gth)
+$  transaction-0
  $%  [%success =info token=(unit @t) finis=finis-0]
      [%failure =info token=(unit @t) error=(unit error)]
      [%pending =info token=(unit @t)]
  ==
+$  finis-0
  $:  transaction-id=@ud
      authorization-code=@ud
      cvv-result=@tas
  ==
--

