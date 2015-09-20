require! './main.css'

require! { querystring, 'html-entities': { XmlEntities } }

title = window.location.pathname |> (.substr 1) |> decode-URI-component

unless title

  root = document.get-element-by-id \content

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


  document.create-element \h1
    ..text-content = title |> (+ \?) |> new XmlEntities!.encode
    root.append-child ..

  content = document.create-element \div
    root.append-child ..


  post '/poll/stats' { title } on-reply = (data, vote) !->
    if data.voted?
      content.inner-HTML = "Yes: #{data.yes}<br />No: #{data.no}<br />You voted: #{data.voted}"
      return

    document.create-element \button
      ..innerText = 'Yes'
      ..onclick = !-> post '/poll/yes' { title } !-> on-reply it
      content.append-child ..

    document.create-element \button
      ..innerText = 'No'
      ..onclick = !-> post '/poll/no'  { title } !-> on-reply it
      content.append-child ..
