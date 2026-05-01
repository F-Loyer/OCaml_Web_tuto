open Tyxml

let render ~table ~logged ~csrf_token =
  let table' = table in
  Format.asprintf "%a" (Html.pp ())
    Html.(html 
     (head
        (title (txt "Database error"))
        [
          style [
            txt {css|
h1 {
  border-bottom-style:solid;
  border-bottom-width:5px;
  border-bottom-color:#844;
  font-family: Verdana, sans-serif; 
  font-style: italic;
}

    table { border-collapse: collapse; border: 2px solid #08c;}
    td, th { border: 1px solid #08c; padding: 8px; }
    input { width:300px; margin:5px; }
    button { margin:5px; }
                 |css} ]
     ])
     (body (
        [
          h1 [ txt "Private" ]
        ]
        @
        (if logged then
           [
             p [ txt "You are logged." ];
             p [ a ~a:[ a_href "private" ]
                   [ txt "private directory" ]];
             p [ a ~a:[ a_href "/logout.html" ]
                   [ txt "Logout" ]];
           ]
         else
           [
             p [ a ~a:[ a_href "/login.html" ] [ txt "Login" ]];
           ]
        )
        @
        [
          h1 [ txt "T1 table" ];
          table (
            [
              tr ~a:[ a_style "background: #08C" ] [
                td [
                  form ~a:[ a_action "#"; a_method `Post ] [
                    input ~a:[ a_input_type `Hidden;
                               a_name "dream.csrf";
                               a_value csrf_token ] ();
                    input ~a:[ a_input_type `Text;
                               a_name "value"; a_value "" ] ();
                    button ~a:[ a_button_type `Submit;
                                a_name "action";
                                a_text_value "insert" ]
                      [ txt "Insert" ]
                    ]
                  ]
                ] 
            ]
            @
            List.map (fun (id, value) ->
              tr [
                td [
                  form ~a:[ a_action "#"; a_method `Post ] [
                      input ~a:[ a_input_type `Hidden;
                                 a_name "id";
                                 a_value (string_of_int id) ] ();
                      input ~a:[ a_input_type `Hidden;
                                 a_name "dream.csrf";
                                 a_value csrf_token ] ();
                      input ~a:[ a_input_type `Text;
                                 a_name "value";
                                 a_value value ] ();
                      button ~a:[ a_button_type `Submit;
                                  a_name "action";
                                  a_text_value "change" ]
                        [ txt "Change" ];
                      button ~a:[ a_button_type `Submit;
                                  a_name "action";
                                  a_text_value "delete" ]
                        [ txt "Delete" ];
                    ]
                  ]
                ]
              ) table'
            )
        ]
        )
     )
  )

