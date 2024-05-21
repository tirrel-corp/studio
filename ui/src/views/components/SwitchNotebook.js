import { useContext, useEffect, useState } from 'react';
import { StoreContext } from '../../logic/Store';
import { pathToResource } from '../utils/index';

const SwitchNotebook = props => {
  const { initial, onChange } = props;

  const { pipe, groups } = useContext(StoreContext);

  const initialDiary = 'diary/'+initial.split('/').slice(2).join('/');

  const notebooks = Object.entries(groups || {})
    .reduce((res, [k, v]) => {
      return res.concat(Object.entries(v.channels))
        .filter(([k, v]) => {
          const type = k.split('/')[0];
          if (type !== 'diary') return false;
          const ship = k.split('/')[1].slice(1);
          const name = k.split('/')[2];
          const init = initial.split('/')[3];
          const flows = Object.keys(pipe?.flows || {});
          if (name === init) return true;
          return (!flows.includes(name) && ship === window.ship);
        });
    }, []);

  const [init, setInit] = useState();
  useEffect(() => {
    if (init) {
      return;
    }
    if (notebooks[0]?.[0]) {
      setInit(true);
      onChange(notebooks[0][0]);
    }
  }, [init, notebooks, onChange]);

  return (
    <div>
      <p>Select a notebook to convert into a site:</p>
      {!notebooks.length ? (
        <p>You have no unpublished notebooks!</p>
      ) : (
        <form>
          <select
            onChange={ev => onChange(ev.target.value)}
            defaultValue={initial}
          >
            <option disabled value="">Please select a notebook</option>
            {notebooks.map(([id, v]) => (
              <option value={id} key={id}>
                {v.meta.title}{initialDiary === id ? ' (Current)' : ''}
              </option>
            ))}
          </select>
        </form>
      )}
    </div>
  );
};

export { SwitchNotebook };
