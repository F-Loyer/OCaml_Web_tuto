# Jingoo
## Introduction

Despite the templating proposed by Dream, you may prefer a template
system similar to
[Django](https://docs.djangoproject.com/en/4.0/topics/templates/) or
[Jinja](https://realpython.com/primer-on-jinja-templating/) on
Python. This is what proposes Jingoo. This has a neater syntax, but
its ".jingoo" files are not compiled (and their errors are detected at
run time while the Dream template would have raised an error at
compile
time). See [Jingoo GitHub page](https://github.com/tategakibunko/jingoo).

This second example replaces the Dream templating by Jingoo. The
Jingoo integration will be developped. See the [first
example](../01-dream) for the description of the other matters.

## Model preparation

Before rendering a jingoo file, a model must be agregated and includes
all data, taggued with their type and associated with the name used by
the jingoo template.

The following snippet tags each data with its type (`Tbool`, `Tstr`,
`Tint`, `Tlist`, `Tset` (tuple)).  The templating funtion of Jingoo is
called afterwards.

```ocaml
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
```

## The jingoo template file

The jingoo template file uses two conventions: `%` for control
sequence (here if/else/endif and for/endfor), and `{{ value }}` for
values to be outputed. Note the `csrf_flag|safe` for variable that
must be outputed with not HTML quotation.

```ocaml
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
{% if logged %}
  <p>You are logged.</p>
  <p><a href="private">private directory</a></p>
  <p><a href="/logout.html">Logout</a></p>
{% else %}
  <p><a href="/login.html">Login</a></p>
{% endif %}
   <h1>T1 table</h1>
   <table>
     <tr><th>Value</th><th>Actions</th></tr>
       <tr style="background:#08C">
         <form action="#" method="POST" style="display:inline">
      {{ csrf_tag|safe }}
      <td><input type="value" name="value" value=""></td>
      <td><button type="submit" name="action" value="insert">add</button></td>
      </form></tr>
{% for (id, value) in table %}
      <tr>
        <form action="#" method="POST" style="display:inline">
        {{ csrf_tag|safe }}
        <input type="hidden" name="id" value="{{ id }}">
        <td><input type="value" name="value" value="{{ value }}"></td>
        <td>
        <button type="submit" name="action" value="change">change</button>
        <button type="submit" name="action" value="delete">delete</button>
        </td>
      </form></tr>
{% endfor %}
  </table>
</body>
</html>
```

