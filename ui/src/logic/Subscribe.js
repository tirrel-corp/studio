import Urbit from '@urbit/http-api';


const Subscribe = (setStore) => {
  let api = new Urbit('', '', 'studio');
  api.ship = window.ship;

  let subscribe = (app, path) => {
    api.subscribe({
      app: app,
      path: path,
      event: (json) => setStore({ app, data: json }),
      quit: (qui) => subscribe.call(this),
      err: (err) => console.error(err)
    });
  };

  let initialScry = (app, path) => {
  }

  subscribe('pipe', '/updates');
  subscribe('mailer', '/updates');
  subscribe('switchboard', '/update');
  subscribe('auth', '/all');
  subscribe('groups', '/groups/ui');
  subscribe('diary', '/ui');

  api.scry({app: 'groups', path: '/groups'}).then((json =>
    setStore({app: 'groups', data: json, scry: true})
  ));

  api.scry({app: 'diary', path: '/shelf'}).then((json) =>{
    Object.keys(json).forEach((key) => {
      let ship = (key.split('/')[0].slice(1));
      if (ship === window.ship) {
        api.scry({app: 'diary', path: `/diary/${key}/notes/newer/0/999`}).then((json) =>{
          setStore({app: 'diary', data: json, scry: true, key: key})
        })
      }
    });
  });


  return api;
};

export { Subscribe };
