window.onload = function onload () {
  var protocol = document.location.protocol === "https:" ? "wss:" : "ws:";
  var address = document.location.host + document.body.dataset.script;
  var websocket = new WebSocket(protocol + "//" + address);

  websocket.onmessage = function onmessage (message) {
    document.getElementById("svg").innerHTML = message.data;
  };

  websocket.onerror = function onerror (error) {
    if (websocket.readyState === 3) {
      console.error("In order to get hot reloading working, you need to have faye-websocket in your Gemfile.");
    }
  }
};
