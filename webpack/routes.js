import React from 'react';
import { Route } from 'react-router';
import App from './containers/App';
import Planets from './components/planets.js';
import Planet from './components/planet.js';
import NoMatch from './components/NoMatch';
import Header from './components/header.js';

export default (
  <Route>
    <Route path="/" component={App} />
    <Route path="/planets" component={Planets} />
    <Route path="/:x/:y/:z" component={Planet} />
    <Route path="*" status={404} component={NoMatch}/>
  </Route>
)

