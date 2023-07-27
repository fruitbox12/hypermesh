const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json());

app.post('/hypercore/:action', async (req, res) => {
  const action = req.params.action;
  const params = req.body;
  switch(action) {
    case 'announce':
      module.exports.announce(params.name, params.keyPair);
      break;
    case 'unannounce':
      module.exports.unannounce(params.name);
      break;
    case 'lookup':
      const result = await module.exports.lookup(params.name);
      res.json(result);
      return;
    default:
      res.status(400).json({ error: 'Invalid action' });
      return;
  }
  res.json({ status: 'ok' });
});

const WEBHOOK_PORT = 3000;
app.listen(WEBHOOK_PORT, () => {
  console.log(`Hypercore webhook server listening on port ${WEBHOOK_PORT}`);
});
