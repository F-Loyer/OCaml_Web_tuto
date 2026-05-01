open Tyxml

let render ~error =
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
    input { width: 30%; box-sizing: border-box; }
    td input { width: 100%; box-sizing: border-box; }
    form { display: inline; margin: 0; }
     th:nth-child(1) { width: 400px; } td:nth-child(3) { width: 60px;}
     th:nth-child(2) { width: 120px; } 
                         |css} ]
            ])
            (body [
                 h1 [ txt "Database error" ];
                 p [ txt "The following error has occur: " ; txt error ];
                 p [
                     a ~a:[ a_href "/" ] [ txt "Home page" ]
                 ]
               ]
            )      
  )
