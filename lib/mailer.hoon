/-  *mailer
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  [%send-email email]
        [%set-creds (ot api-key+(mu so) email+(mu so) ship-url+(mu so) ~)]
        [%unset-creds (ot api-key+bo email+bo ship-url+bo ~)]
        [%add-list (ot name+so list+(as so) ~)]
        [%del-list (ot name+so ~)]
        [%add-recipients (ot name+so list+(as so) ~)]
        [%del-recipients (ot name+so list+(as so) ~)]
        [%create-campaign-template (ot name+so from+(ot email+so name+so ~) email-sequence+(ar (ot subject+so content+so ~)) ~)]
        [%start-campaign (ot name+so template-name+so recipients+recipients interval+date-relative ~)]
        [%del-campaign-template (ot name+so ~)]
        [%del-campaign (ot name+so ~)]
    ==
  ++  recipients
    |=  jon=json
    ^-  (each @t term)
    ?>  ?=([%o *] jon)
    =/  which=json  (~(got by p.jon) 'which')
    ?>  ?=([%b *] which)
    =/  what=json  (~(got by p.jon) 'what')
    ?>  ?=([%s *] what)
    ?:  p.which  [%.y p.what]
    [%.n `@tas`p.what]
  ++  date-relative
    |=  jon=json
    ^-  @dr
    ?>  ?=([%n *] jon)
    =/  num=@  (rash p.jon dem)
    (mul ~s1 num)
  ++  email
    %-  ot
    :~  from+(ot email+so name+so ~)
        subject+so
        content+(ar (ot type+so value+so ~))
        personalizations+(ar personalization)
    ==
  ++  personalization
    %-  ot
    :~  to+(ar so)
        headers+(as (at so so ~))
        substitutions+(ar (at so so ~))
    ==
  --
::
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  u=^update
    ^-  json
    %+  frond  -.u
    ?-  -.u
        %initial
      %-  pairs
      :~  creds+(creds creds.u)
          mailing-lists+(mailing-lists ml.u)
          campaign-templates+(campaign-templates campaign-templates.u)
          campaigns+(campaigns campaigns.u)
      ==
    ==
  ::
  ++  creds
    |=  [api-key=(unit @t) email=(unit @t) ship-url=(unit @t)]
    ^-  json
    %-  pairs:enjs:format
    :~  api-key+?~(api-key ~ s+u.api-key)
        email+?~(email ~ s+u.email)
        ship-url+?~(ship-url ~ s+u.ship-url)
    ==
  ::
  ++  mailing-lists
    |=  m=(map term ^mailing-list)
    ^-  json
    :-  %o
    (~(run by m) mailing-list)
  ::
  ++  mailing-list
    |=  m=^mailing-list
    ^-  json
    :-  %a
    %+  turn  ~(tap by m)
    |=  [w=@t *]
    [%s w]
  ::
  ++  campaign-templates
    |=  templates=(map term ^campaign-template)
    ^-  json
    :-  %o
    (~(run by templates) campaign-template)
  ::
  ++  campaign-template
    |=  template=^campaign-template
    ^-  json
    %-  pairs:enjs:format
    :~  from+(from-field from.template)
        email-sequence+(email-sequence email-sequence.template)
    ==
  ::
  ++  from-field
    |=  from=^from-field
    ^-  json
    %-  pairs:enjs:format
    :~  name+s+name.from
        email+s+email.from
    ==
  ::
  ++  email-sequence
    |=  emails=(map @ud email-list-item)
    ^-  json
    %-  pairs:enjs:format
    =/  map-1=(map @ud json)
      (~(run by emails) email-sequence-item)
    =/  list-1=(list [@ud json])  ~(tap by map-1)
    %+  turn  list-1
    |=  [key=@ud value=json]
    [(crip <key>) value]
  ::
  ++  email-sequence-item
    |=  [prev=(unit @ud) next=(unit @ud) body=(unit [subject=cord content=cord])]
    ^-  json
    %-  pairs:enjs:format
    :~  prev+(unit-number prev)
        next+(unit-number next)
        body+(unit-email-body body)
    ==
  ::
  ++  unit-number
    |=  item=(unit @ud)
    ^-  json
    ?~  item  ~
    [%s (crip <u.item>)]
  ::
  ++  unit-email-body
    |=  item=(unit [subject=cord content=cord])
    ^-  json
    ?~  item  ~
    %-  pairs:enjs:format
    :~  subject+s+subject.u.item
        content+s+content.u.item
    ==
  ::
  ++  campaigns
    |=  email-campaigns=(map term ^campaign)
    ^-  json
    :-  %o
    (~(run by email-campaigns) campaign)
  ::
  ++  campaign
    |=  email-campaign=^campaign
    ^-  json
    %-  pairs:enjs:format
    :~  template-name+s+template-name.email-campaign
        next-time+(time:enjs:format next-time.email-campaign)
        interval-seconds+(date-relative-seconds interval.email-campaign)
        recipients+(recipients recipients.email-campaign)
    ==
  ::
  ++  date-relative-seconds
    |=  date=@dr
    ^-  json
    (numb:enjs:format (div date ~s1))
  ::
  ++  recipients
    |=  rec=(each @t term)
    ^-  json
    =/  type=@t
    ?:  ?=(%.y -.rec)
      'SINGLE_ADDRESS'
    'MAILING_LIST'
    =/  value=@t  p.rec
    %-  pairs:enjs:format
    :~  type+s+type
        value+s+value
    ==
  --
--
