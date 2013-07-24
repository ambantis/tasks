window.app ?= {}
app = window.app

ENTER_KEY = 13

# The Application
# ---------------

# Our overall **AppView** is the top-level piece of UI
app.appView = Backbone.View.extend

  # Instead of generating a new element, bind to the existing skeleton of
  # the App already present in the HTML
  el: '#taskapp'

  # Our template for the line of statistics at the bottom of the app.
  statsTemplate: _.template $('#stats-template').html()

# Delegated events for creating new items, and clearing completed ones
  events:
    'keypress #new-task': 'createOnEnter'
    'click #clear-completed': 'clearCompleted'
    'click #toggle-all': 'toggleAllComplete'

  # At initialization
  initialize: ->
    @allCheckbox = this.$('#toggle-all')[0]
    this.$input = this.$('#new-task')
    this.$footer = this.$('#footer')
    this.$main = this.$('#main')

    @listenTo app.tasks, 'add', @addOne
    @listenTo app.tasks, 'reset', @addAll
    @listenTo app.tasks, 'change:completed', @filterOne
    @listenTo app.tasks, 'filter', @filterAll
    @listenTo app.tasks, 'all', @render

    app.tasks.fetch()

  # Re-rendering the App just means refreshing the statistics -- the rest
  # of the app doesn't change.
  render: ->
    completed = app.tasks.completed().length
    remaining = app.tasks.remaining().length

    if (app.tasks.length)
      this.$main.show()
      this.$footer.show()
      this.$footer.html @statsTemplate
        completed: completed
        remaining: remaining
      this.$('#filters li a')
        .removeClass('selected')
        .filter("[href=\"#/#{app.taskFilter || ''}\"]")
        .addClass('selected')
    else
      this.$main.hide()
      this.$footer.hide()

    @allCheckbox.checked = !remaining

  # Add a single item to the list by creating a view for it, and
  # appending its element to the `<ul>`.
  addOne: (task) ->
    view = new app.taskView { model: task }
    $('#task-list').append view.render().el

  # Add all items in the **Tasks** collection at once.
  addAll: ->
    this.$('#task-list').html('')
    app.tasks.each @addOne, this

  filterOne: (task) ->
    task.trigger 'visible'

  filterAll: ->
    app.tasks.each @filterOne, this

  newAttributes: ->
    title: this.$input.val().trim()
    order: app.tasks.nextOrder()
    completed: false

  createOnEnter: (event) ->
    if event.which is ENTER_KEY and this.$input.val().trim()
      app.tasks.create @newAttributes()
      this.$input.val ''

  # Clear all completed task items, destroying their models
  clearCompleted: ->
    _.invoke app.tasks.completed(), 'destroy'
    return false

  toggleAllComplete: ->
    completed = @allCheckbox.checked
    app.tasks.each (task) -> task.save
      'completed': completed

