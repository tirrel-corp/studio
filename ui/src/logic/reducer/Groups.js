
const GroupsReducer = (state, update) => {
  if (typeof update.data !== 'object') return state;
  if (update.app !== 'groups') return state;
  if (update.scry) {
    state = update.data;
  }
  const resource = update?.data?.flag;
  const diff = update?.data?.update?.diff;
  if (diff?.create) {
    return { ...state, ...{ [resource]: diff.create } }
  }
  if (diff && 'del' in diff) {
    const deletedState = (({ [resource]: _, ...o }) => o)(state)
    return deletedState
  }
  return state;
}

export { GroupsReducer };
