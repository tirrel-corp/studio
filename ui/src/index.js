import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter, Routes, Route } from "react-router-dom";

import { App } from './views/App';
import { Index } from './views/Index';
import { NewSite } from './views/NewSite/';
import { Site } from './views/Site';
import { AddPlugin } from './views/Site/AddPlugin/index';
import { ConfigurePipe } from './views/Site/AddPlugin/ConfigurePipe';
import Settings from "./views/Settings/index";

import { SubscriberDetails } from './views/Site/PluginDetails/SubscriberDetails';
import { PipeDetails } from './views/Site/PluginDetails/PipeDetails';
import { PaywallDetails } from './views/Site/PluginDetails/PaywallDetails';

import './index.css';

ReactDOM.render(
  <React.StrictMode>
    <BrowserRouter basename="/apps/studio">
      <Routes>
        <Route path="/" element={<App />}>
          <Route path="" element={<Index />} />
          <Route path="new" element={<NewSite />} />
          <Route path="site">
            <Route path=":name">
              <Route path="" element={<Site />} />
              <Route path="subscribers" element={<SubscriberDetails />} />
              <Route path="paywall" element={<PaywallDetails />} />
              <Route path="pipe/:pluginName" element={<PipeDetails />} />
              <Route path="add-plugin">
                <Route path="pipe" element={<ConfigurePipe />} />
              </Route>
            </Route>
          </Route>
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>,
  document.getElementById('root')
);
