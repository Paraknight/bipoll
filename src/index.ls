#require! './clear.styl'

require! { querystring, 'html-entities': { XmlEntities } }

title = window.location.pathname |> (.substr 1) |> decode-URI-component

unless title
  document.create-element \h1
    ..text-content = 'Welcome to BiPoll'
    document.body.append-child ..
  document.create-element \p
    ..text-content = 'Plz nav to URL like "bipoll.com/do you agree?".'
    document.body.append-child ..
else
  post = (url, data, callback) !->
    xhr = new XMLHttpRequest!
    xhr.onload = !-> @response-text |> JSON.parse |> callback
    xhr.open \POST url
    xhr.set-request-header \content-type 'application/x-www-form-urlencoded'
    xhr.send querystring.stringify data


  document.create-element \h1
    ..text-content = title |> (+ \?) |> new XmlEntities!.encode
    document.body.append-child ..

  content = document.create-element \div
    document.body.append-child ..


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
