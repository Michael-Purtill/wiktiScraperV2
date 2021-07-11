// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";

import App from "./components/App.svelte";
import Lang from "./components/Lang.svelte";
import TestPage from "./components/TestPage.svelte";
import Unmatched from "./components/Unmatched.svelte";
import Dict from "./components/Dict.svelte";


var target = document.querySelector("#app");
new App({ target, props: {} });

var target = document.querySelector("#lang");
new Lang({ target, props: {} });

var target = document.querySelector("#testPage");
new TestPage({target, props: {}});

var target = document.querySelector("#unmatched");
new Unmatched({target, props: {}});

var target = document.querySelector("#dict");
new Dict({target, props: {}});