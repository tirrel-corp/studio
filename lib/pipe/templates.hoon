/-  *pipe
/+  pipe-templates-site-light-basic,
    pipe-templates-site-dark-basic,
    pipe-templates-site-dark-urbit,
    pipe-templates-site-light-urbit,
    pipe-templates-email-light
|%
++  site-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%light-basic pipe-templates-site-light-basic]
      [%light-urbit pipe-templates-site-light-urbit]
      [%dark-basic pipe-templates-site-dark-basic]
      [%dark-urbit pipe-templates-site-dark-urbit]
  ==
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
