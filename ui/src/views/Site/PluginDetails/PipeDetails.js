import { useContext, useRef, useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { StoreContext } from '../../../logic/Store';
import { pathToResource, makeFormData, trimSlash } from '../../utils/index';
import { SwitchNotebook } from '../../components/SwitchNotebook';
import * as valid from '../../utils/validators';
import ThemeEditor from '../../components/ThemeEditor';
import LoadOverlay from "../../components/LoadOverlay";
import Style from '../../components/Style';
import Layout from '../../components/Layout';

const PipeDetails = props => {
  const { name: siteName, pluginName } = useParams();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState();
  const [resource, setResource] = useState({});
  const [showEditor, setShowEditor] = useState(false);
  const { api, switchboard, pipe } = useContext(StoreContext);
  const title = switchboard?.[siteName]?.title || '';
  const { binding, plugins: myPlugins = {} } = switchboard?.[siteName] || {};
  const sitePath = binding ? `${trimSlash(binding?.hostname)}${trimSlash(binding?.path)}` : '';
  const byName = new Map(
    Object.entries(myPlugins).map((
      ([path, { name, type }]) => ([name, { name, path, type }])
    ))
  )
  const thisPlugin = byName.get(pluginName);
  const thisFlow = pipe?.flows?.[pluginName];
  const { name = '', ship = '' } = thisFlow?.resource || {};
  const currentResourcePath = `/ship/~${ship}/${name}`;
  const currentStyle = thisFlow?.style;
  const currentComments = thisFlow?.site?.comments;
  const currentLayout = thisFlow?.site?.template;
  const currentHeadline = thisFlow?.site?.headline;
  const currentProfile = thisFlow?.site?.['profile-img'];
  const currentHeader = thisFlow?.site?.['header-img'];
  const [layout, setLayout] = useState(currentLayout);

  useEffect(() => {
    setLayout(currentLayout);
  }, [currentLayout]);

  const dialogRef = useRef();

  const deletePlugin = () => {
    const threadParams = {
      inputMark: 'pipe-thread',
      outputMark: 'tang',
      threadName: 'remove-pipe-plugin',
      desk: 'studio',
      body: {
        "remove": {
          'site-name': siteName,
          'plugin-name': pluginName,
          'sub-path': thisPlugin.path,
        },
      }
    };

    setLoading(true);
    api.thread(threadParams)
      .then(() => navigate('../'))
      .catch(err => {
        setLoading(false);
        setError(err.message)
      });
  };

  const editPlugin = (params) => {
    const threadParams = {
      inputMark: 'pipe-thread',
      outputMark: 'tang',
      threadName: 'edit-pipe-plugin',
      desk: 'studio',
      body: {
        "edit": {
          'site-name': siteName,
          'old-sub-path': thisPlugin.path,
          'new-sub-path': params['sub-path'] || '/',
          'old-plugin-name': pluginName,
          'new-plugin-name': params.resource.name,
          comments: params.comments || false,
          resource: params.resource,
          style: params.style,
          template: params.layout,
          headline: params.headline || '',
          profile: params.profile || '',
          header: params.header || '',
        },
      },
    };
    setLoading(true);
    api.thread(threadParams)
      .then(() => navigate('../'))
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
        setShowEditor(false)
        return setLoading(false)
      })
      .catch(err => {
        setLoading(false)
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
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{title}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>

          <div className="flex flex-column" style={{ gap: '1rem', minHeight: '50vh' }}>
            {loading && <LoadOverlay />}
            <div className="flex justify-between items-center" style={{ gap: '1rem' }}>
              <h2>Blog Configuration</h2>
              <button
                className="danger"
                disabled={!thisPlugin}
                onClick={ev => {
                  // triggers form onSubmit for some reason, so we have to stop it
                  ev.preventDefault();
                  ev.stopPropagation();
                  dialogRef.current.showModal();
                }}
              >
                &#215;&nbsp;Delete
              </button>
            </div>
            <SwitchNotebook
              onChange={path => setResource(pathToResource(path))}
              initial={currentResourcePath}
            />
            <form
              className="flex flex-column"
              style={{ gap: '1rem' }}
              onSubmit={ev => {
                ev.preventDefault();
                ev.stopPropagation();
                const toSubmit = makeFormData(ev.target);
                editPlugin({ ...toSubmit, resource });
              }}>
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
                  placeholder={thisPlugin?.path}
                  pattern={valid.pathPattern}
                />
              </div>
              <fieldset name="layout">
                <legend className="pa1">Select a layout</legend>
                <Layout name="Basic List" val="basic" layout={layout} setLayout={setLayout} currentLayout={currentLayout}/>
                <Layout name="Grid" val="grid" layout={layout} setLayout={setLayout} headline={currentHeadline} profile={currentProfile} header={currentHeader} />
              </fieldset>
              <br/>
              <fieldset name="style">
                <legend className="pa1">Select a theme</legend>
                {Object.entries(pipe?.styles || {}).map(([name, values]) => {
                  return <Style key={name} name={name} deleteTheme={() => deleteTheme(name)} currentStyle={currentStyle} addTheme={addTheme} values={values} />
                })}
              </fieldset>
              <div className="mv3">
                <button onClick={(e) => {
                  e.preventDefault()
                  setShowEditor(!showEditor)
                }}>Create new theme</button>
                {showEditor && <ThemeEditor onSave={(name, colors, font) => addTheme(name, colors, font)} />}
              </div>
              <div>
                <p>
                  Check this box to show comments from your urbit notebook on your site.
                </p>
                <input
                  className="ma1"
                  type="checkbox"
                  id="comments"
                  name="comments"
                  defaultChecked={currentComments}
                />
                <label htmlFor="comments">Show Notebook Comments</label>
              </div>
              <div className="flex justify-end pt3" style={{ marginTop: 'auto' }}>
                <button type="submit" disabled={!thisPlugin}>
                  Save &#10003;
                </button>
              </div>
            </form>
            <dialog ref={dialogRef}>
              <div className="flex flex-column">
                <h1>Confirm Deletion</h1>
                <p>
                  Continuing will delete this plugin permanently. Are you sure you
                  want to do this?
                </p>
                <div className="flex flex-row-reverse mt4" style={{ gap: '1rem' }}>
                  <button className="danger" onClick={() => deletePlugin()}>
                    Confirm Deletion
                  </button>
                  <button onClick={() => dialogRef.current.close()}>
                    Cancel
                  </button>
                </div>
              </div>
            </dialog>
          </div>
        </div>
      </div>
    </div>
  );
};

export { PipeDetails };
