Introduction
============

Emacs Lisp Module to add [trepan-xpy](https://github.com/rocky/trepan-xpy/) support to [realgud](http://github.com/realgud/realgud).


Installation
=============

From github source
------------------

* Have `realgud` and `test-simple` installed.
* From inside GNU Emacs, evaluate:
```lisp
  (compile (format "EMACSLOADPATH=:%s:%s ./autogen.sh" (file-name-directory (locate-library "test-simple.elc")) (file-name-directory (locate-library "realgud.elc"))))
```

[travis-image]: https://api.travis-ci.org/realgud/realgud-lldb.svg?branch=master
[travis-url]: https://travis-ci.org/realgud/realgud-lldb
[melpa-stable-image]: http://stable.melpa.org/packages/realgud-lldb-badge.svg
[melpa-stable]: http://stable.melpa.org/#/realgud-lldb
[melpa-image]: http://melpa.org/packages/realgud-lldb-badge.svg
[melpa]: http://melpa.org/#/realgud-lldb
