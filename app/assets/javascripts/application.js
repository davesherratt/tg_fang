// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery-ujs
//= require react
//= require react_ujs
//= require react-router
//= require react-router-dom
//= require react-bootstrap-table
//= require_tree ./components
window.$ = window.jQuery = global.$ = require('jquery');

var React = window.React = global.React = require('react');

require( 'fetch' );
import { Home } from './components/Home';