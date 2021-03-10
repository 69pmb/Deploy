const compression = require('compression');
const express = require('express');
const path = require('path');

const app = express();

app.use(compression());
app.use(express.static(__dirname + '/dist'));

app.get('/*', function(req,res) {
    res.sendFile(path.join(__dirname + '/dist/index.html'));
});
app.listen({{port}});
