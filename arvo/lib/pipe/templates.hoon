/-  *pipe
/+  pipe-templates-site-basic,
    pipe-templates-site-grid,
    pipe-templates-email-light
|%
++  site-templates
  ^-  (map term versioned-site-template)
  %-  ~(gas by *(map term versioned-site-template))
  :~  [%basic pipe-templates-site-basic]
      [%grid pipe-templates-site-grid]
  ==
++  email-templates
  ^-  (map term versioned-email-template)
  %-  ~(gas by *(map term versioned-email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
