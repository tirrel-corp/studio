import { createContext } from 'react';

const initialStore = {
  loaded: {
    all: false,
    switchboard: false,
    pipe: false,
    mailer: false,
    groups: false,
    auth: false,
    diary: false,
  },
  switchboard: {},
  pipe: {},
  mailer: {},
  groups: {},
  diary: {},
  auth: {
    services: {},
    kyc: false,
  },
  api: null
};

const StoreContext = createContext();


export { StoreContext, initialStore };

