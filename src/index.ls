require! './main.styl'

require! { querystring, 'html-entities': { XmlEntities } }

title = window.location.pathname |> (.substr 1) |> decode-URI-component

root = document.get-element-by-id \content

unless title
  root.inner-HTML = (require './home.pug')!
else
  post = (url, data, callback) !->
    xhr = new XMLHttpRequest!
    xhr.onload = !-> @response-text |> JSON.parse |> callback
    xhr.open \POST url
    xhr.set-request-header \content-type 'application/x-www-form-urlencoded'
    xhr.send querystring.stringify data

  root.style.height = "100%"

  html-title = title |> (+ \?) |> new XmlEntities!.encode

  root.inner-HTML = (require './question.pug') title: html-title

  post '/poll/stats' { title } on-reply = (data, vote) !->
    if data.voted?
      document.get-element-by-id \buttons .inner-HTML = (require './stats.pug') data
      return

    document
      ..get-element-by-id \buttons .inner-HTML = (require './buttons.pug')!
      ..get-element-by-id \yes-button .onclick = !-> post '/poll/yes' { title } !-> on-reply it
      ..get-element-by-id \no-button  .onclick = !-> post '/poll/no'  { title } !-> on-reply it
