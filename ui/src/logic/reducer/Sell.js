
const SellReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val  = update.data[key];
  switch (update.app) {
  case 'naive-nmi':
    switch (key) {
    case 'set-site':
      state.nmi.site = val;
      break;
    case 'set-api-key':
      state.nmi.apiKey = val;
      break;
    case 'set-redirect-url':
      state.nmi.redirectUrl = val;
      break;
    default:
      throw new Error("error");
    }
    return state;
  //
  case 'naive-market':
    switch (key) {
    case 'add-star-config':
      if (!('stars' in state.market)) {
        state.market.stars = {};
      }
      state.market.stars[val.who] = val.config;
      break;
    case 'del-star-config':
      if (!('stars' in state.market)) {
        state.market.stars = {};
      }
      delete state.market.stars[val];
      break;
    case 'set-price':
      state.market.price = val;
      break;
    case 'set-referrals':
      state.market.referrals = val;
      break;
    default:
      throw new Error("error");
    }
    return state;
  default:
    return state;
  }
};

export { SellReducer };

