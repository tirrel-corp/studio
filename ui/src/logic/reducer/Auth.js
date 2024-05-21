const AuthReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val = update.data[key];
  switch (update.app) {
    case 'auth':
      if (key === 'add-service') {
        state.services[val.name] = val.service;
      } else if (key === 'del-service') {
        delete state.services[val.name];
      } else if (key === 'add-subscribers') {
        Object.keys(val.users).forEach((k, i) => {
          val.users[k] = {
            "security-clearance": true,
            "mailing-list": true,
            free: val.users[k]
          };
        });
        state.services[val.name].users = {
          ...state.services[val.name].users,
          ...val.users
        }
      } else if (key === 'add-user') {
        state.services[val.name].users.push(val.user);
      } else if (key === 'del-user') {
        delete state.services[val.name].users[val.user];
          //= state.services[val.name].users.filter((u) => {
//          return u !== val.user;
      } else if (key === 'set-kyc') {
        state.kyc = val;
      } else if (key === 'payout-status') {
        state[key] = val
      } else if (key === 'mod-details') {
        state.services[val.name].pricing = val.pricing;
        state.services[val.name].title = val.title;
        state.services[val.name].copy = val.copy;
        state.services[val.name].shipping = val.shipping;
      }
      break;
    default:
      break;
  }

  return state;
}

export { AuthReducer };
