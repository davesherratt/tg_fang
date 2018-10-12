import React from 'react';
import $ from 'jquery';
import ReactDOM from 'react-dom';
import { Router, browserHistory } from 'react-router';

import BootstrapTable from './package/react-bootstrap-table.min.js';
import routes from './routes';

ReactDOM.render(
  <Router history={browserHistory} routes={routes} />,
  document.getElementById('app')
);

