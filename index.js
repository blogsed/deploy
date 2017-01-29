const handler = require("./config/lambda").handler;

handler("foo", "bar", function() {
  console.log("callback called with:  " + Array.prototype.slice.call(arguments));
});
