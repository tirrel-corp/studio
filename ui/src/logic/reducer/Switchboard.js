export const SwitchboardReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val  = update.data[key];
  if (update.app !== 'switchboard') return state;
  switch (key) {
    case 'full':
      state = val;
      break;
    case 'add-site':
      state[val.name] = {
        binding: {
          hostname: val.hostname,
          path: val.path,
        },
        title: val.title,
        plugins: {},
      };
      break;
    case 'edit-site':
      state[val.name] = {
        binding: {
          hostname: val.hostname,
          path: val.path,
        },
        title: val.title,
        plugins: {},
      };
      break;
    case 'del-site':
      delete state[val.name];
      break;
    case 'add-plugin':
      state[val.name].plugins[val.path] = val.plugin;
      break;
    case 'del-plugin':
      delete state[val.name].plugins[val.path];
      break;
    default:
      break;
  }
  return state;
};
