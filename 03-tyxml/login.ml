open Tyxml

let render ~csrf_token =
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
  border-bottom-color:#08C;
  font-family: Verdana, sans-serif; 
  font-style: italic;
}

    button {
      margin-top: 0em;
      padding: 0.5em 1.5em;
      font-size: 1em;
      background-color: #08C;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
    }
                          |css} ]
            ])
            (body (
                 [
                   h1 [ txt "Authentication" ];
                   form ~a:[ a_action "#"; a_method `Post ] [
                       input ~a:[ a_input_type `Hidden; a_name "dream.csrf"; a_value csrf_token ] ();
                       input ~a:[ a_input_type `Text; a_name "username"; a_placeholder "Username" ] ();
                       input ~a:[ a_input_type `Password; a_name "password"; a_placeholder "Password" ] ();
                       button ~a:[ a_button_type `Submit ] [ txt "Login" ]
                     ]
                 ]
               )
            )
  )
