$ ->

  # js/views/app.coffee

  ENTER_KEY = 13

  # The Application
  # ---------------


  # Our overall **AppView** is the top-level piece of UI
  AppView = Backbone.View.extend

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

      @listenTo Tasks, 'add', @addOne
      @listenTo Tasks, 'reset', @addAll
      @listenTo Tasks, 'change:completed', @filterOne
      @listenTo Tasks, 'filter', @filterAll
      @listenTo Tasks, 'all', @render

      Tasks.fetch()

  # Re-rendering the App just means refreshing the statistics -- the rest
  # of the app doesn't change.
    render: ->
      completed = Tasks.completed().length
      remaining = Tasks.remaining().length

      if (Tasks.length)
        this.$main.show()
        this.$footer.show()
        this.$footer.html @statsTemplate
          completed: completed
          remaining: remaining
        this.$('#filters li a')
          .removeClass('selected')
          .filter("[href=\"#/#{TaskFilter || ''}\"]")
          .addClass('selected')
      else
        this.$main.hide()
        this.$footer.hide()

      @allCheckbox.checked = !remaining

  # Add a single item to the list by creating a view for it, and
  # appending its element to the `<ul>`.
    addOne: (task) ->
      view = new TaskView { model: task }
      $('#task-list').append view.render().el

  # Add all items in the **Tasks** collection at once.
    addAll: ->
      this.$('#task-list').html('')
      Tasks.each @addOne, this

    filterOne: (task) ->
      task.trigger 'visible'

    filterAll: ->
      Tasks.each @filterOne, this

    newAttributes: ->
      title: this.$input.val().trim()
      order: Tasks.nextOrder()
      completed: false

    createOnEnter: (event) ->
      if event.which is ENTER_KEY and this.$input.val().trim()
        Tasks.create @newAttributes()
        this.$input.val ''

  # Clear all completed task items, destroying their models
    clearCompleted: ->
      _.invoke Tasks.completed(), 'destroy'
      false

    toggleAllComplete: ->
      completed = @allCheckbox.checked
      Tasks.each (task) -> task.save
        'completed': completed

  # App Task
  # js/models/task.coffee
  Task = Backbone.Model.extend

    defaults:
      title: ''

    toggle: -> @save {completed: !this.get('completed')}

# ------------------------------------------------------------------


  # Task Collection
  # js/collections/task.coffee
  #----------------

  # The collection of tasks is backed by *localStorage* instead of a remote
  # server.
  TaskList = Backbone.Collection.extend

  # Reference to this collection's model.
    model: Task

  #  Save all of the tasks items under the `"tasks-backbone"` namespace.
    localStorage: new Backbone.LocalStorage 'tasks-backbone'

  # Filter down the list of all task items that are finished
    completed: -> @filter (task) -> task.get 'completed'

  # Filter down the list of all task items that are not finished
    remaining: -> @without.apply(this, @completed)

  # We keep the toDos in sequential order, despite being saved by unordered
  # GUID in the database. This generate the next order number for new items
    nextOrder: -> unless @length then 1 else @last().get('order') + 1

  # toDos are sorted by their original insertion order.
    comparator: (task) -> task.get 'order'


# -----------------------------------------------------------------------


  # Task Item View
  #---------------

  # The DOM element for a task item...
  TaskView = Backbone.View.extend

  # ... is a list tag.
    tagName: 'li'

  # Cache the template function for a single item.
    template: _.template $('#item-template').html()

  # The DOM elements specific to an item.
    events:
      'click .toggle': 'togglecompleted'
      'dbleclick label': 'edit'
      'click .destroy': 'clear'
      'keypress .edit': 'updateOnEnter'
      'blur .edit': 'close'

  # The TaskView listens for changes to its model, re-rendering. Since there's
  # a one-to-one correspondence between a **Task** and a **TaskView** in this
  # app, we set a direct reference on the model for convenience.
    initialize: ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'destroy', @remove
      @listenTo @model, 'visible', @toggleVisible

  # Re-renders the titles of the task item.
    render: ->
      this.$el.html( @template( @model.toJSON() ) )
      this.$el.toggleClass 'completed', @model.get 'completed'
      @toggleVisible
      this.$input = this.$('.edit')
      return this

  # Toggles visibility of item
    toggleVisible: ->
      this.$el.toggleClass 'hidden', @isHidden

  # Determines if item should be hidden
    isHidden: ->
      isCompleted = @model.get 'completed'
      (not isCompleted and TaskFilter is 'completed') or (isCompleted and TaskFilter is 'active')

  # Toggle the `"completed"` state of the model
    toggleCompleted: ->
      @model.toggle()

  # Switch this view into `"editing"` mode, saving changes to the task
    edit: ->
      this.$el.addClass 'editing'
      this.$input.focus()

  # Close the `"editing"` mode, saving changes to the task.
    close: ->
      value = this.$input.val().trim()
      if value then @model.save { title: value } else @clear()
      this.$el.removeClass 'editing'

    updateOnEnter: (event) ->
      if (event.which is ENTER_KEY) @close() else return

    clear: ->
      @model.destroy()

# ----------------------------------------------------------------------------------------------

  Workspace = Backbone.Router.extend
    routes:
      '*filter': 'setFilter'

    setFilter: (param) ->
      # Set the current filter to be used
      if (param) then param = param.trim()
      TaskFilter = param or ''

      # Trigger a collection filter event, causing hiding/unhiding
      # of Task view items
      Tasks.trigger 'filter'

  Tasks = new TaskList()
  TodoRouter = new Workspace()

  new TaskView()
  Backbone.history.start()

