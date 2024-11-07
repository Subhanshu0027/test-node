const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello, Buddy!');
});

// Listen on all network interfaces (0.0.0.0) to make the app accessible externally
app.listen(port, '0.0.0.0', () => {
  console.log(`App running at http://0.0.0.0:${port}`);
});
