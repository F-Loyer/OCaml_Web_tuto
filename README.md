# OCaml Web tutorials
## Introduction

This page gives you a short glimpse of multiple OCaml Web
frameworks. A simple application will stress multiple aspects of
typical application: rendering, form processing, database query,
security.

Note: the (sql) file is intended to initialise a SQL database used by
these exemples.

## Dream

Dream is a nice Web framework that permits you to route your
application call between different rendering and processing
functions. It comes with a templating system (but doesn't mandate
it. It handles many use cases and is well documented with many
use-case example. See
[Dream documentation page](https://camlworks.github.io/dream/). 

[Dream example](01-dream)

## Dream and Jingoo

Despite the templating proposed by Dream, you may prefer a template
system similar to
[Django](https://docs.djangoproject.com/en/4.0/topics/templates/) or
[Jinja](https://realpython.com/primer-on-jinja-templating/) on
Python. This is what proposes Jingoo. This has a neater syntax, but
its ".jingoo" files are not compiled (and their errors are detected at
run time while the Dream template would have raised an error at
compile
time). See [Jingoo Github page[(https://github.com/tategakibunko/jingoo).

[Jingoo example](02-jingoo)

## Dream and TyXML

The templating approach proposed by Dream may also be replaced by
TyXML. This does not work like template-based string extrapolation,
but rather uses a set of functions eponymous to HTML tags. These
functions build the HTML result and guarantee that it is well-formed.
See [the TyXML page](https://ocsigen.org/tyxml/latest/manual/intro)

[TyXML example](03-tyxml/index.html">TyXML example)
