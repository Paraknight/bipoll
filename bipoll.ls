require! { express, 'body-parser' }

app = express!

app.use '/static' express.static 'build'

app.get '/*' (req, res) !-> res.send-file 'build/index.html' root: './'

app.use body-parser.urlencoded extended: false

app.post '/poll/yes' (req, res) !->
  unless req.body.title
    res.write-head 400
    res.end!
    return
  res.end JSON.stringify do
    voted: \yes
    yes: 100
    no: 20

app.post '/poll/no' (req, res) !->
  unless req.body.title
    res.write-head 400
    res.end!
    return
  res.end JSON.stringify do
    voted: \no
    yes: 100
    no: 20

app.post '/poll/stats' (req, res) !->
  unless req.body.title
    res.write-head 400
    res.end!
    return
  res.end JSON.stringify do
    voted: \no
    yes: 100
    no: 20

app.listen 9980
