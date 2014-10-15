

module.exports = (app, config) ->
  if !config? or !config.port?
    throw new Error("Port must be defined.")
  else
    app.start()
