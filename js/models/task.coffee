# js/models/task.js
#
window.app ?= {}
app = window.app

app.Task = Backbone.Model.extend

  defaults:
    title: ''
    completed: false

  toggle: ->
    @save
      completed: !@get 'completed'