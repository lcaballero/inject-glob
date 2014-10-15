require('./globals')
glob      = require('glob')
{ Tree }  = require('nject')
path      = require('path')
async     = require('async')


defaults =
  globs         : [ '**/*.js', '**/*.coffee', '**/*.json' ]
  cwd           : '.'
  interceptName : (f) -> injectName(f)
  aggregateOn   : ->

###
  Uses the name of the file as the key for the registered item.  For instance,
  if the name of the file is middleware/sqlPool.coffee it will register the
  function exported from sqlPool.coffee as the value for the key 'sqlPool'.

  Once an item is registered other code can then be injected with that value.
  So, for instance in controllers/HomeController.js if that function were to
  be defined like so: `(sqlPool, config) ->` it would be injected with the
  the registered value for `sqlPool` and `config`.
###
injectName = (file) ->
  f   = path.basename(file)
  ext = path.extname(f)
  f.substring(0, f.length - ext.length)


register = (cwd, tree, f, interceptName, aggregateOn) ->
  file = path.resolve(cwd, f)
  name = interceptName(f, injectName)

  req  = require(file)

  if _.isPlainObject(req)
    tree.constant(name, req)
  else if _.isFunction(req)
    tree.register(name, req, aggregateOn(f))

search = (opts) -> (g, next) -> glob(g, opts, next)

apply = (opts, cb) ->
  { globs, cwd, interceptName, aggregateOn } = _.defaults({}, opts, defaults)

  async.mapSeries(globs, search(opts), (err, res) ->
    if err?
      cb(err, null)
    else
      tree  = new Tree()
      files = _.flatten(res)

      for f in files
        register(cwd, tree, f, interceptName, aggregateOn)

      tree.resolve(cb)
  )

module.exports = _.defaults(apply, {
  injectName  : injectName
  register    : register
  defaults    : defaults
})
