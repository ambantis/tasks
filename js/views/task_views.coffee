# js/views.js
window.app ?= {}
app = window.app
# Task Item View
#---------------

# The DOM element for a task item...
app.taskView = Backbone.View.extend

  # ... is a list tag.
  tagName: 'li'

  # Cache the template function for a single item.
  template: _.template $('#item-template').html()

  # The DOM elements specific to an item.
  events:
    'click .toggle': 'toggleCompleted'
    'dblclick label': 'edit'
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
    this.$el.html @template( @model.toJSON())
    this.$el.toggleClass 'completed', @model.get 'completed'
    @toggleVisible
    this.$input = this.$('.edit')
    return this

  # Toggles visibility of item
  toggleVisible: ->
    this.$el.toggleClass 'hidden', @isHidden()

  # Determines if item should be hidden
  isHidden: ->
    isCompleted = @model.get 'completed'
    (not isCompleted and app.taskFilter is 'completed') or (isCompleted and app.taskFilter is 'active')

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
    if (event.which is ENTER_KEY) then @close()

  clear: ->
    @model.destroy()