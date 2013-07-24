# js/routers/router.js

# Task router
#------------
window.app ?= {}
app = window.app

Workspace = Backbone.Router.extend
  routes:
    '*filter': 'setFilter'

  setFilter: (param) ->
    # Set the current filter to be used
    if (param) then param = param.trim()
    app.taskFilter = param or ''

    # Trigger a collection filter event, causing hiding/unhiding
    # of Task view items
    app.tasks.trigger 'filter'

app.todoRouter = new Workspace()
Backbone.history.start()