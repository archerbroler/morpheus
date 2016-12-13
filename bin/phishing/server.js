var express = require('express')
var app = express()

app.use((req, res) => {
  if (req.query.xss) res.setHeader('X-XSS-Protection', req.query.xss)
  res.send(`<h1>Hello, ${req.query.user || 'anonymous'}</h1>`)
})

app.listen(1234)
