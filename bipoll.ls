require! { url, express, 'body-parser', 'html-entities': { XmlEntities } }

app = express!

app.use '/static' express.static 'build'

entities = new XmlEntities!

app.get '/*' (req, res) !-> res.send-file 'build/index.html' root: './'

app.use body-parser.urlencoded extended: false

app.post '/poll/yes' (req, res) !->
  return unless req.body.title
  console.log req.body.title
  res.end!

app.post '/poll/no' (req, res) !->
  return unless req.body.title
  console.log req.body.title
  res.end!

app.listen 9980
