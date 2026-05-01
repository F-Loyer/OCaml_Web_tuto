# Dream
## Introduction

Dream is a nice Web framework that permits you to route your
application call between different rendering and processing
functions. It comes with a templating system (but doesn't mandate
it). It handles many use cases and is well documented with many
use-case example. See [Dream documentation
page](https://camlworks.github.io/dream/).

This first example assembles Dream and its templating framework, Caqti
(a database library compatible with SQlite, Postgres, MySql/MariaDB),
and ppx_reaper (a preprocessor that makes it easier to use Caqti).

## Main function, routing table

The (main.ml) file runs the whole framework with a routing table.

```ocaml
let () =
  Dream.run ~port:8181 ~interface:"0.0.0.0" (* ~interface:"127.0.0.1" *)
  @@ Dream.logger
  @@ Dream.sql_pool
       ("mariadb://login:password@localhost/test")
  @@ Dream.sql_sessions ~lifetime:(200.*.86400.)
  @@ Dream.set_secret "AZERTYUIKJNBVFCDS" (* Used by CSRF tokens *)
  @@ Dream.router
       [
         Dream.get "/lost.html" @@ Dream.static file_path;
         Dream.get "/" (fun request -> Dream.redirect request "/t1.html");
         Dream.get "/t1.html" @@ render_t1;
         Dream.post "/t1.html" @@ process_t1;
         Dream.get "/login.html" @@ render_login;
         Dream.post "/login.html" @@ process_login;
         Dream.any "/logout.html" @@ render_logout;
         Dream.any "/private" @@
           (fun request -> Dream.redirect request "/private/index.html");
         Dream.scope "/private" [ filter_admin ]
           [
             Dream.any "/**" @@ Dream.static (file_path ^ "/private");
           ];
         Dream.any "/**" @@
           (fun request -> Dream.redirect request "/lost.html")
]
```

We can see different route handlers. `Dream.get`, `Dream.post` or
`Dream.any`, match some file patterns and HTML queries, and need
_handlers_ which are functions that process them. Some functions are
already provided (`Dream.static` for serving static files and
`Dream.redirect` for redirections), but we may use custom functions.

`Dream.scope` handles a whole directory and needs a list of
_middleware_ and another routing table. Usually, an empty list of
middleware is adequate, but here, a custom `filter_admin` middleware
enforce a security filter at the whole directory.

## A simple rendering handler

The following handler prepare the data to be rendered and calls
`Render_t1.render` which does the actual template rendering.

```ocaml
let ( let*? ) = Lwt_result.bind

let render_t1 request =
  Dream.sql request (fun db ->
      let*? table = get_t1 ~db in
      let body =
        Render_t1.render ~table ~csrf_tag:(Dream.csrf_tag request)
          ~logged:(is_logged request)
      in
      Lwt_result.return (Dream.html body))
  |> process_caqti_error
```

We note that because of the SQL request `get_t1`, the result must be a
`Lwt_result`. Here `let*?` allows you to chain easily multiple
`Lwt_result` (here, `get_t1` and `Lwt_result.return`). The end result
is processed by `process_caqti_error` which renders an error page if
the result is an error. It is defined by:

```ocaml
let process_caqti_error result =
  match%lwt result with
  | Ok x -> x
  | Error error ->
     let error = Caqti_error.show error in
     Dream.log "Caqti:%s" error;
     let body = Render_dberror.render ~error in
     Dream.html body       
```

The database query is defined by the simple query:

```ocaml
let get_t1 ~db =
  [%rapper
    get_many
      {sql|
       SELECT @int{id}, @string{value}
       FROM t1
       ORDER BY id
       |sql}]
    () db
```

Where each input parameters are tagged with the pattern `@type{param}`
(the `%type{param}` is used in other queries for parameters given to
the query). The preprocessor ppx_rapper transforms this string into a
funtion that takes `() db` as parameters and returns a list of tuples
`(id, value)`.

ppx_rapper has many options which are described on
the [ppx_rapper GitHub site](https://github.com/roddyyaga/ppx_rapper)

The actual rendering is provided in a `.eml` files like:

```ocaml
let render ~table ~logged ~csrf_tag =
<html>
<head>
<style>
h1 {
  border-bottom-style:solid;
  border-bottom-width:5px;
  border-bottom-color:#08C;
  font-family: Verdana, sans-serif; 
  font-style: italic;
}
    table { border-collapse: collapse; border: 2px solid #08c;}
    td, th { border: 1px solid #08c; padding: 8px; }
    input { width: 30%; box-sizing: border-box; }
    td input { width: 100%; box-sizing: border-box; }
    form { display: inline; margin: 0; }
     th:nth-child(1) { width: 400px; } td:nth-child(3) { width: 60px;}
     th:nth-child(2) { width: 120px; } 
    </style>
    </head>
 <body>
   <h1>Private</h1>
% if logged then (
  <p>You are logged.</p>
  <p><a href="private">private directory</a></p>
  <p><a href="/logout.html">Logout</a></p>
% ) else (
  <p><a href="/login.html">Login</a></p>
% );
   <h1>T1 table</h1>
   <table>
     <tr><th>Value</th><th>Actions</th></tr>
       <tr style="background:#08C">
         <form action="#" method="POST" style="display:inline">
      <%s! csrf_tag %>
      <td><input type="value" name="value" value=""></td>
      <td><button type="submit" name="action" value="insert">add</button></td>
      </form></tr>
% List.iter (fun (id, value) ->
      <tr>
        <form action="#" method="POST" style="display:inline">
        <%s! csrf_tag %>
        <input type="hidden" name="id" value="<%d id %>">
        <td><input type="value" name="value" value="<%s value %>"></td>
        <td>
        <button type="submit" name="action" value="change">change</button>
        <button type="submit" name="action" value="delete">delete</button>
        </td>
      </form></tr>
% ) table;                                     
  </table>
</body>
</html>
```     

We notice the `% ...` form which interlaces OCaml code especially for
control code (conditionals, loops), `<%d var %>`, `<%s var %>` and
`<%s! var %>` for variable outputing. the `<%s!` is for raw output (no
HTML quoting) in cases we are sure not to mess the HTML structure (XSS
attacks...).

