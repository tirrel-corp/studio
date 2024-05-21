import { useContext, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { SelectNotebook } from '../../components/SelectNotebook';
import { StoreContext } from '../../../logic/Store';
import { pathToResource, makeFormData, trimSlash } from '../../utils/index';
import * as valid from '../../utils/validators';
import ThemeEditor from "../../components/ThemeEditor"
import LoadOverlay from '../../components/LoadOverlay';
import Style from '../../components/Style';
import Layout from '../../components/Layout';

const ConfigurePipe = props => {
  const { name } = useParams();
  const navigate = useNavigate();
  const { api, switchboard, pipe } = useContext(StoreContext);
  const { hostname, path } = switchboard?.[name]?.binding || {};
  const title = switchboard?.[name]?.title || '';
  const sitePath = hostname && path ? `${trimSlash(hostname)}${trimSlash(path)}` : undefined;
  const [showEditor, setShowEditor] = useState(false);
  const [resource, setResource] = useState({});
  const [loading, setLoading] = useState();
  const [error, setError] = useState();

  const [layout, setLayout] = useState();

  const configurePipe = (params) => {
    const threadParams = {
      inputMark: 'pipe-thread',
      outputMark: 'tang',
      threadName: 'add-pipe-plugin',
      desk: 'studio',
      body: {
        "add":  {
          ...params,
          'sub-path': params['sub-path'] || '/',
          'site-name': name,
          comments: params.comments || false,
          style: params.style,
          template: params.layout,
          headline: params.headline || '',
          profile: params.profile || '',
          header: params.header || '',
        },
      },
    }
    setLoading(true)

    api.thread(threadParams)
      .then(() => navigate('../../'))
      .catch(err => {
        setLoading(false)
        setError(err.message)
      });
  };

  const addTheme = (name, colors, font) => {
    const pokeParams = {
      app: 'pipe',
      mark: 'pipe-action',
      json: {
        'set-style': {
          "name": name || 'no-name',
          style: colors.reduce((obj, item) => (obj[`--${item.name}`] = item.color, obj), { font: font.files.regular })
        }
      }
    }
    setLoading(true)
    return api.poke(pokeParams)
      .then(() => {
        setShowEditor(false);
        return setLoading(false)
      })
      .catch(err => {
        setLoading(false);
        console.error(err.message)
      });
  }

  const deleteTheme = (name) => {
    const pokeParams = {
      app: 'pipe',
      mark: 'pipe-action',
      json: {
        'set-style': {
          "name": name || 'no-name',
          style: {}
        }
      }
    }
    setLoading(true)
    return api.poke(pokeParams)
      .then(() => {
        setShowEditor(false)
        return setLoading(false)
      })
      .catch(err => {
        setLoading(false);
        console.error(err.message)
      });
  }

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      {loading && <LoadOverlay />}
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{title}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
          <h2>New Publication</h2>
          <SelectNotebook onChange={path => setResource(pathToResource(path))} />
          <form
            className="flex flex-column"
            style={{ gap: '1rem' }}
            onSubmit={ev => {
              ev.preventDefault();
              ev.stopPropagation();
              const toSubmit = makeFormData(ev.target);
              configurePipe({ ...toSubmit, resource });
            }}>
            <input
              id="plugin-name"
              name="plugin-name"
              type="hidden"
              value={resource?.name || ''}
              pattern={valid.tasPattern}
            />
            <div>
              <p>
                Configure the path where published content will appear.
              </p>
              <label htmlFor="sub-path">
                {sitePath && (<span><code>{sitePath}</code></span>)}
              </label>
              <input
                id="sub-path"
                name="sub-path"
                className="mt1 ml1 code"
                placeholder="/"
                pattern={valid.pathPattern}
              />
            </div>

            <fieldset name="layout" className="mb2">
              <legend className="pa1">Select a layout</legend>
              <Layout name="Basic List" val="basic" layout={layout} setLayout={setLayout} />
              <Layout name="Grid" val="grid" layout={layout} setLayout={setLayout} />
            </fieldset>

            <fieldset name="style">
              <legend className="pa1">Select a theme</legend>
              {Object.entries(pipe?.styles || {}).map(([name, values]) => {
                return <Style key={name} name={name} deleteTheme={() => deleteTheme(name)} addTheme={addTheme} values={values} />
              })}
            </fieldset>
            <div className="mv3">
              <button onClick={(e) => {
                e.preventDefault()
                setShowEditor(!showEditor)
              }}>Create new theme</button>

              {showEditor && <ThemeEditor
                onSave={(name, colors, font) => addTheme(name, colors, font)}
              />}
            </div>
            <div>
              <p>
                Check this box to show comments from your urbit notebook on
                your site.
              </p>
              <input className="ma1" type="checkbox" id="comments" name="comments" />
              <label htmlFor="comments">Show Notebook Comments</label>
            </div>
            <div className="flex justify-end pt3" style={{ marginTop: 'auto' }}>
              <button type="submit">
                Confirm&nbsp;&#10003;
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
};

export { ConfigurePipe };
