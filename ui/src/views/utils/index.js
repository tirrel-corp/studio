import { useEffect, useState, useCallback } from 'react';
import { Button } from './Button';
import { Col } from './Col';
import { Loading } from './Loading';
import { Row } from './Row';

function eventToState(setter) {
  return (e) => {
    setter(e.target.value);
  };
}

function makeFormData(target) {
  const data = new FormData(target);
  const toSubmit = Object.fromEntries([...data.entries()]
    // convert checkbox values to booleans
    .map(([k, v]) => ([k, v === "on" ? true : v])));
  return toSubmit;
}

function pathToResource(path) {
  let res = path.split('/');
  return {
    ship: res[1],
    name: res[2]
  };
}

function isValidURL(input) {
  try {
    const stripped = input.replaceAll(/http(s)?:\/\//g, '');
    new URL(`https://${stripped}`);
    return true;
  } catch (err) {
    return false;
  }
}

function isValidPath(input) {
  return (input.startsWith('/') && isValidURL(`tirrel.io${input}`)) || input === '';
}

function trimSlash(input) {
  if (!input) {
    return input;
  }
  if (input.slice(-1) === '/') {
    return input.slice(0, -1);
  } else {
    return input;
  }
}

function getContentUrls({ switchboard }) {
  return Object.fromEntries(Object.entries(switchboard || {})
    .map(([name, { binding: { hostname, path }, plugins, title }]) => {
      let pipePlugins = Object.fromEntries(Object.entries(plugins)
        .filter(([path, { name, type }]) => { return type === 'pipe' }));
      hostname = trimSlash(hostname);
      path = trimSlash(path);
      let plugin = (Object.keys(pipePlugins).length > 0) ?
        trimSlash(Object.keys(pipePlugins)[0]) : '';
      return [
        name,
        {  url: Object.keys(plugins).length
              ? `http://${hostname}${path}${plugin}`
              : undefined,
          title: title
        }
      ]
    })
  )
}

const noop = (..._) => undefined;
function useKeydown(keys, handler = noop) {
  // keys is a string or an array of strings
  if (!(typeof keys === 'string'
    || (Array.isArray(keys) && keys.every(k => typeof k === 'string'))
  )) {
    throw new Error('bad keys for useKeydown');
  }
  if (typeof handler !== 'function') {
    throw new Error('bad handler for useKeydown');
  }

  const listener = useCallback((event) => {
    if (Array.isArray(keys) ? keys.includes(event.key) : keys === event.key) {
      handler?.(event);
      event.preventDefault();
    }
  }, [keys, handler]);

  useEffect(() => {
    window.addEventListener('keydown', listener);
    return () => window.removeEventListener('keydown', listener);
  }, [listener]);
};

const useCopy = (copied) => {
  const [didCopy, setDidCopy] = useState(false);
  const doCopy = useCallback(() => {
    let success = false;
    function listener(e) {
      e.clipboardData.setData('text/plain', copied);
      e.preventDefault();
      success = true;
    }

    document.addEventListener('copy', listener);
    document.execCommand('copy');
    document.removeEventListener('copy', listener);

    setDidCopy(true);
    setTimeout(() => {
      setDidCopy(false);
    }, 2000);
  }, [copied]);

  return doCopy;
}

const formatUsd = new Intl.NumberFormat('en-US', {
  minimumSignificantDigits: 2,
  maximumSignificantDigits: 2
});

const makeStringSafe = (str) => {
  let res = ''
  let lastChar = ''
  let code;
  let chr;
  str = str.toLowerCase();
  for (var i=0; i<str.length; i++) {
    code = str.charCodeAt(i);
    chr  = str.charAt(i);
    if ( (code >= 97 && code <= 122) ||
         (code >= 65 && code <= 90)  ||
         (chr === '-') ||
         (chr === '_') ||
         (chr === '.') ||
         (chr === '~') ) {
      res =res.concat(chr);
      lastChar = chr;
    } else {
      if (lastChar !== '-' && lastChar !== '') {
        res = res.concat('-');
        lastChar = '-';
      }
    }
  }
  return res;
}

export {
  Button,
  Col,
  Loading,
  Row,
  eventToState,
  makeFormData,
  getContentUrls,
  isValidURL,
  isValidPath,
  pathToResource,
  useKeydown,
  trimSlash,
  formatUsd,
  useCopy,
  makeStringSafe
};
