open Jingoo

let file_path = "/home/loyer/tuto_ocaml/01-dream"

(* let (let* ) = Lwt.bind *)
let ( let*? ) = Lwt_result.bind

let process_caqti_error result =
  match%lwt result with
  | Ok x -> x
  | Error error ->
     let error = Caqti_error.show error in
     Dream.log "Caqti:%s" error;
     let body =
        Jg_template.from_file "render_dberror.jingoo" ~models:[
            ("error", Jg_types.Tstr error)
          ] in
     Dream.html body

let rec _get_from_list attr assoc_list =
  match attr with
  | item :: tl -> List.assoc_opt item assoc_list :: _get_from_list tl assoc_list
  | [] -> []

(* Requests *)
        
let get_t1 ~db =
  [%rapper
    get_many
      {sql|
       SELECT @int{id}, @string{value}
       FROM t1
       ORDER BY id
       |sql}]
    () db

let insert_t1 ~value ~db =
  [%rapper
      execute
      {sql|
       INSERT INTO t1 (value)
       VALUES (%string{value})
       |sql}]
    ~value db
   
let change_t1 ~value ~id ~db =
  [%rapper
    execute
      {sql|
       UPDATE t1 SET value=%string{value}
       WHERE id=%int{id}
       |sql}]
    ~value ~id db

let delete_t1 ~id ~db =
  [%rapper
    execute {sql|
       DELETE FROM t1 WHERE id=%int{id}
       |sql}]
    ~id db

let is_logged request =
  match Dream.session_field request "code" with
  | Some "authenticated" -> true
  | _ -> false

let render_t1 request =
  Dream.sql request (fun db ->
      let*? table = get_t1 ~db in
      let body =
        Jg_template.from_file "render_t1.jingoo" ~models:[
            ("csrf_tag", Jg_types.Tstr (Dream.csrf_tag request));
            ("table", Jg_types.Tlist
                        (List.map
                           (fun (id, value) ->
                             Jg_types.Tset [Tint id; Tstr value])
                           table));
            ("logged",Jg_types.Tbool (is_logged request))
          ]
      in
      Lwt_result.return (Dream.html body))
  |> process_caqti_error

let process_t1 request =
  Dream.sql request (fun db ->
      (* We must catch each set of arguments, in alphabetic order *)
      match%lwt Dream.form request with
      | `Ok [ ("action", "change"); ("id", id); ("value", value) ] ->
         let*? () =
           change_t1 ~value ~id:(int_of_string id) ~db
         in
         Lwt_result.return (render_t1 request)
      | `Ok [ ("action", "insert"); ("value", value) ] ->
         let*? () =
            insert_t1 ~value ~db
          in
          Lwt_result.return (render_t1 request)
      | `Ok [ ("action", "delete"); ("id", id); ("value", _) ] ->
          let*? () = delete_t1 ~id:(int_of_string id) ~db in
          Lwt_result.return (render_t1 request)
      | `Ok list ->
          List.iter
            (fun (name, value) -> Dream.log "FORM %s : %s" name value)
            list;
          Lwt_result.return (Dream.html "FORM error")
      | _ -> Lwt_result.return (Dream.html "error"))
  |> process_caqti_error

(* ******** *)

  
let filter_admin handler request =
  if is_logged request then
    handler request
  else
    Dream.redirect request "login.html"

let render_login request =
  let body =
    Jg_template.from_file "login.jingoo" ~models:[
        ("csrf_tag", Jg_types.Tstr (Dream.csrf_tag request));
      ]
  in
  Dream.html body

let process_login request =
  match%lwt Dream.form request with
  | `Ok [ ("password", "abc"); ("username", "admin") ] ->
      let%lwt () = Dream.set_session_field request "code" "authenticated" in
      Dream.redirect request "/"
  | _ -> Dream.redirect request "/login.html"

let render_logout request =
  let%lwt () = Dream.set_session_field request "code" "BANNED" in
  Dream.redirect request "/"

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
