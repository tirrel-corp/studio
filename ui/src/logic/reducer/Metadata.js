
const MetadataReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val  = update.data[key];
  if (update.app !== 'metadata-store') return state;
  let metakey = Object.keys(val)[0];
  let metaval = val[metakey];
  switch (metakey) {
    case 'associations':
      for (let i in metaval) {
        let association = metaval[i];
        if (association['app-name'] !== 'graph') continue;
        if (association.metadata.config.graph !== 'publish') continue;
        if (association.metadata.creator.slice(1) !== window.ship) continue;
        let res = association.resource;
        state[res] = association;
      }
      break;
    case 'add':
      if (metaval['app-name'] !== 'graph') break;
      if (metaval.metadata.config.graph !== 'publish') break;
      if (metaval.metadata.creator.slice(1) !== window.ship) break;
      let res = metaval.resource;
      state[res] = metaval;
      break;
    case 'remove':
      delete state[metaval.resource];
      break;
    default:
      break;
  }
  return state;
}

export { MetadataReducer };
