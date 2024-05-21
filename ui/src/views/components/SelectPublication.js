import { useContext, useEffect, useState } from 'react';
import { StoreContext } from '../../logic/Store';

const noop = (..._) => undefined;

const SelectPublication = props => {
  const { onChange = noop } = props;

  const { pipe, groups } = useContext(StoreContext);

  const notebooks = Object.fromEntries(
    Object.entries(groups || {})
    .reduce((res, [k, v]) => {
      return res.concat(Object.entries(v.channels))
    }, []));

  const publishedNotebooks = Object.keys(pipe?.flows || {});
  const titlesByName = Object.fromEntries(
    publishedNotebooks
      .map(name => {
        const { ship = '' } = pipe?.flows?.[name]?.resource;
        return [
          name,
          notebooks?.[`diary/~${ship}/${name}`]?.meta?.title
        ];
      })
  );

  const [init, setInit] = useState(false);
  useEffect(() => {
    if (init) {
      return;
    }
    if (publishedNotebooks.length) {
      setInit(true);
      onChange(publishedNotebooks[0]);
    }
  }, [init, publishedNotebooks]);

  return (
    <>
      {!publishedNotebooks.length ? (
        <p>No publications to choose from!</p>
      ) : (
        <form>
          <label htmlFor="publication" className="db">Publication</label>
          <select
            id="publication"
            name="publication"
            className="mt2"
            onChange={ev => onChange(ev.target.value)}
          >
            <option disabled value="">Please select a publication</option>
            {Object.entries(titlesByName).map(([name, title]) => (
              <option value={name} key={name}>
                {title}
              </option>
            ))}
          </select>
        </form>
      )}
    </>
  );
};

export { SelectPublication };
