import { useState, useEffect } from "react";
import ThemeEditor from "./ThemeEditor";
export default function Layout({ name, val, layout, setLayout, headline, profile, header}) {
  const [checked, setChecked] = useState(val === layout);
  useEffect(() => {
    setChecked(val === layout);
  }, [layout]);

  return (
    <div className="flex flex-column mv2">
      <div className='flex items-center'>
          <input
              className="mr2"
              type="radio"
              id={`layout-${val}`}
              name="layout"
              value={val}
              onChange={(e) => setLayout(val)}
              checked={checked}
          />
          <label htmlFor={`style-${val}`}>{name}</label>
      </div>
      {(layout === val && name === "Grid") &&
        <>
        <div className="mt2">
          <label htmlFor="headline">
            Description:
          </label>
          <input
            id="headline"
            name="headline"
            className="ml2"
            defaultValue={headline}
          />
        </div>
        <div className="mt2">
          <label htmlFor="profile">
            Profile Image URL:
          </label>
          <input
            id="profile"
            name="profile"
            className="ml2"
            defaultValue={profile}
          />
        </div>
        <div className="mt2">
          <label htmlFor="header">
            Header Image URL:
          </label>
          <input
            id="header"
            name="header"
            className="ml2"
            defaultValue={header}
          />
        </div>
        </>
      }
  </div>
  );
}
