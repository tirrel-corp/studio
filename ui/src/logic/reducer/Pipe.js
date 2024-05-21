
const PipeReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val = update.data[key];
  if (update.app !== 'pipe') return state;
  switch (key) {
    case 'flows':
      state.flows = val;
      break;
    case 'templates':
      state.templates = val;
      break;
    case 'styles':
      state.styles = val;
      break;
    case 'errors':
      state.errors = val;
      break;
    default:
      break;
  }
  return state;
}

export { PipeReducer };
