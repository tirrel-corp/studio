import { useContext } from 'react';
import { StoreContext } from '../../logic/Store';

const SelectTemplate = props => {
  const { onChange } = props;

  const { pipe } = useContext(StoreContext);

  const templates = pipe?.templates?.site || [];
  const onChangeTemplate = ev => onChange([ev.target.value, undefined]);
  const onChangeTheme = ev => onChange([undefined, ev.target.value]);

  return (
    <form className="flex flex-column" style={{gap: "1rem"}}>
      <div>
        <label htmlFor="template" className="db f6 b">Template</label>
        <select id="template" onChange={onChangeTemplate}>
          <option disabled value="">Please select a template</option>
          {templates.map(t => (
            <option value={t} key={t}>{t}</option>
          ))}
        </select>
      </div>
      <div>
        <label htmlFor="theme" className="db f6 b">Theme</label>
        <select id="theme" onChange={onChangeTheme}>
          <option disabled value="">Please select a theme</option>
          <option value="light">light</option>
          <option value="dark">dark</option>
        </select>
      </div>
    </form>
  );
};

export { SelectTemplate };
