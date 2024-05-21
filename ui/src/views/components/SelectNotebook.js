import { useContext, useEffect, useState } from 'react';
import { StoreContext } from '../../logic/Store';
import { pathToResource } from '../utils/index';

const SelectNotebook = props => {
  const { onChange } = props;

  const { pipe, groups } = useContext(StoreContext);

  const notebooks = Object.entries(groups || {})
    .reduce((res, [k, v]) => {
      return res.concat(Object.entries(v.channels))
        .filter(([k, v]) => {
          const type = k.split('/')[0];
          if (type !== 'diary') return false;
          const ship = k.split('/')[1].slice(1);
          const name = k.split('/')[2];
          const flows = Object.keys(pipe?.flows || {});
          return (!flows.includes(name) && ship === window.ship);
        });
    }, []);

  const [init, setInit] = useState(false);
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
          <select onChange={ev => onChange(ev.target.value)}>
            <option disabled value="">Please select a notebook</option>
            {notebooks.map(([id, v]) => (
              <option value={id} key={id}>{v.meta.title}</option>
            ))}
          </select>
        </form>
      )}
    </div>
  );
};

export { SelectNotebook };
