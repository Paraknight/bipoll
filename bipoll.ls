require! { express, 'body-parser', sqlite3 }
sqlite3 = sqlite3.verbose!

db = new sqlite3.Database 'bipoll.db'
db.parallelize !->
  db.run "CREATE TABLE IF NOT EXISTS questions (
    id INTEGER PRIMARY KEY,
    question TEXT NOT NULL UNIQUE ON CONFLICT IGNORE
  )"
  # NOTE: Votes of IPs that have already voted on a question are silently ignored
  db.run "CREATE TABLE IF NOT EXISTS answers (
    question_id INTEGER NOT NULL,
    answer INTEGER NOT NULL,
    ip TEXT NOT NULL,
    CONSTRAINT uc_question_id_ip UNIQUE (question_id, ip) ON CONFLICT IGNORE
  )"

app = express!

app.enable 'trust proxy'

app.use '/static' express.static 'build'

app.get '/*' (req, res) !-> res.send-file 'build/index.html' root: './'

app.use body-parser.urlencoded extended: false

on-db-err = (err, res) ->
  if err?
    res.write-head 500
    res.end!
    return true

handle-vote = (req, res, vote) !->
  unless req.body.title
    res.write-head 400
    res.end!
    return
  db.serialize !->
    db.run "INSERT INTO questions VALUES (NULL, ?)" req.body.title
    err, row <-! db.get "SELECT id FROM questions WHERE question = ?" req.body.title
    return if on-db-err err, res
    qid = row.id
    db.run "INSERT INTO answers VALUES (?, ?, ?)" qid, (if vote is \yes then 1 else 0), req.ip
    db.parallelize !->
      err, noes <-! db.get "SELECT count(*) FROM answers WHERE answer = '0' AND question_id = ?" qid
      return if on-db-err err, res
      err, yeses <-! db.get "SELECT count(*) FROM answers WHERE answer = '1' AND question_id = ?" qid
      return if on-db-err err, res
      res.end JSON.stringify do
        voted: vote
        yes: yeses['count(*)']
        no: noes['count(*)']

app.post '/poll/yes' (req, res) !-> handle-vote req, res, \yes

app.post '/poll/no'  (req, res) !-> handle-vote req, res, \no

app.post '/poll/stats' (req, res) !->
  unless req.body.title
    res.write-head 400
    res.end!
    return

  db.serialize !->
    err, row <-! db.get "SELECT id FROM questions WHERE question = ?" req.body.title
    return if on-db-err err, res
    # Don't bother making a DB question entry until they actually vote
    unless row?
      res.end '{}'
      return
    qid = row.id
    err, row <-! db.get "SELECT answer FROM answers WHERE ip = ? AND question_id = ?" req.ip, qid
    return if on-db-err err, res
    # Serve stats only to those who have already voted
    unless row?
      res.end '{}'
      return
    db.parallelize !->
      err, noes <-! db.get "SELECT count(*) FROM answers WHERE answer = '0' AND question_id = ?" qid
      return if on-db-err err, res
      err, yeses <-! db.get "SELECT count(*) FROM answers WHERE answer = '1' AND question_id = ?" qid
      return if on-db-err err, res
      res.end JSON.stringify do
        voted: if row.answer is 1 then \yes else \no
        yes: yeses['count(*)']
        no: noes['count(*)']

app.listen (process.env.PORT || 9980)
