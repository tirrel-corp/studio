import { AuthReducer } from './reducer/Auth';
import { PipeReducer } from './reducer/Pipe';
import { MailerReducer } from './reducer/Mailer';
import { GroupsReducer } from './reducer/Groups';
import { DiaryReducer } from './reducer/Diary';
import { SwitchboardReducer } from './reducer/Switchboard';

const Reducer = (store, update = null) => {
  if (!update || typeof update !== 'object') {
    return store;
  }

  store = {
    loaded: store.loaded,
    switchboard: SwitchboardReducer(store.switchboard, update),
    pipe:        PipeReducer(store.pipe, update),
    mailer:      MailerReducer(store.mailer, update),
    groups:      GroupsReducer(store.groups, update),
    diary:       DiaryReducer(store.diary, update),
    auth:        AuthReducer(store.auth, update),
    api: ('api' in update) ? update.api : store.api
  };

  store.loaded.switchboard = Object.keys(store.switchboard).length !== 0;
  store.loaded.pipe        = Object.keys(store.pipe).length !== 0;
  store.loaded.mailer      = Object.keys(store.mailer).length !== 0;
  store.loaded.groups      = Object.keys(store.groups).length !== 0;
  store.loaded.diary       = Object.keys(store.diary).length !== 0;
  store.loaded.auth        = Object.keys(store.auth).length !== 0;
  store.loaded.all =
    store.loaded.switchboard  &&
    store.loaded.pipe         &&
    store.loaded.mailer       &&
    store.loaded.auth         &&
    store.loaded.diary        &&
    store.loaded.groups;

  return store;
};

export { Reducer };
