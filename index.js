const express = require('express');
const os = require('os')

const app = express();

app.get('/', (req, res) => {
  var ipAdd = "unknown";
  const netFaces = os.networkInterfaces();
  for (const name of Object.keys(netFaces)) {
    for (const net of netFaces[name]) {
      if (net.family === "IPv4" && net.internal !== true) {
        ipAdd = net.address;
        break;
      }
    }
    if (ipAdd !== "unknown") break;
  }
  res.send("<h1>Informacje o serwerze</h1><b>IP:</b> "
    + ipAdd
    + "<br><b>hostname:</b> "
    + os.hostname()
    + "<br><b>version:</b> "
    + process.env.APP_VERSION);
});

app.listen(8080, () => {
  console.log('Listening on port 8080');
});