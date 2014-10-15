[![Build Status](https://travis-ci.org/lcaballero/inject-glob.svg?branch=master)](https://travis-ci.org/) [![NPM version](https://badge.fury.io/js/inject-glob.svg)](http://badge.fury.io/js/inject-glob)

# Introduction

`inject-glob` is simple wrapper around [nject][nject] and [glob][glob] which
provides a mechanism traverses a directory structure and creates a [dependency
injection][di] tree.

## Installation

```
%> npm install inject-glob --save
```

## Usage

This is the basic usage.  In this usage, where **all** options are defaulted,
then names are derived from file names; no aggregation of any of the injectables
is done, and default globs are used.

```
path  = require('path')
di    = require('inject-glob')

di(null, (err, resolved) -> resolved.app.start())

```

For reference, here are the defaults, where the function `injectName` simply
removes the extension of a file and uses the file name for the name of the
injectable:

```
defaults =
  globs         : [ '**/*.js', '**/*.coffee', '**/*.json' ]
  cwd           : '.'
  interceptName : (f) -> injectName(f)
  aggregateOn   : ->
```

A possibly more complete and detailed version might look like the following.
In this example everything in the `app/model` directory is aggregated on to
`resolved.model`.  The name of the default.json file is mapped to `config`
and so provided on `resolved.config` and injected in functions which need
those value with the normal mechanism `module.exports = (config) ->`.

```
path  = require('path')
di    = require('inject-glob')

opts =
  globs         : [ '**/*.js', '**/*.coffee', '**/*.json' ]
  cwd           : 'app/'
  aggregateOn   : (name) ->
    switch (path.dirname(name))
      when 'app/model' then { aggregateOn: 'model' }
      else undefined
  interceptName : (name, injectName) ->
    switch (name)
      when 'config/default.json' then 'config'
      else injectName(name)

di(null, (err, resolved) -> resolved.app.start())
```

## License

See license file.

The use and distribution terms for this software are covered by the
[Eclipse Public License 1.0][EPL-1], which can be found in the file 'license' at the
root of this distribution. By using this software in any fashion, you are
agreeing to be bound by the terms of this license. You must not remove this
notice, or any other, from this software.


[EPL-1]: http://opensource.org/licenses/eclipse-1.0.txt
[nject]: https://github.com/autoric/nject
[di]: http://en.wikipedia.org/wiki/Dependency_injection
