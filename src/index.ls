require! './main.css'

require! { querystring, 'html-entities': { XmlEntities } }

title = window.location.pathname |> (.substr 1) |> decode-URI-component

root = document.get-element-by-id \content

unless title

  document.create-element \img
    ..src = require "./logo.svg"
    root.append-child ..

  span1 = document.create-element \span
    ..text-content = "bipoll.com/"
  span2 = document.create-element \span
    ..text-content = "Your question here?"
    ..style.color = "grey"

  document.create-element \p
    ..append-child span1
    ..append-child span2
    root.append-child ..
else
  post = (url, data, callback) !->
    xhr = new XMLHttpRequest!
    xhr.onload = !-> @response-text |> JSON.parse |> callback
    xhr.open \POST url
    xhr.set-request-header \content-type 'application/x-www-form-urlencoded'
    xhr.send querystring.stringify data

  root.style.height = "100%"

  question-title = document.create-element \div
    ..class-name = \question-title
    root.append-child ..

  document.create-element \h1
    ..text-content = title |> (+ \?) |> new XmlEntities!.encode
    question-title.append-child ..

  content = document.create-element \div
    ..class-name = \buttons
    root.append-child ..


  post '/poll/stats' { title } on-reply = (data, vote) !->
    if data.voted?
      content.inner-HTML = "Yes: #{data.yes}<br />No: #{data.no}<br />You voted: #{data.voted}"
      return

    document.create-element \button
      ..innerText = 'Yes'
      ..class-name = "vote-button"
      ..onclick = !-> post '/poll/yes' { title } !-> on-reply it
      content.append-child ..

    document.create-element \button
      ..innerText = 'No'
      ..class-name = "vote-button"
      ..onclick = !-> post '/poll/no'  { title } !-> on-reply it
      content.append-child ..
