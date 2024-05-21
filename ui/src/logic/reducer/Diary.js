
const DiaryReducer = (state, update) => {
  if (typeof update.data !== 'object') return state;
  if (update.app !== 'diary') return state;
  if (update.scry) {
    state[update.key] = update.data;
  }
  return state;
}

export { DiaryReducer };
