window.app ?= {}
app = window.app

# Task Collection
#----------------

# The collection of tasks is backed by *localStorage* instead of a remote
# server.
TaskList = Backbone.Collection.extend

  # Reference to this collection's model.
  model: app.Task

  # Save all of the tasks items under the `"tasks-backbone"` namespace.
  localStorage: new Backbone.LocalStorage 'tasks-backbone'

  # Filter down the list of all task items that are finished
  completed: -> @filter (task) -> task.get 'completed'

  # Filter down the list of all task items that are not finished
  remaining: -> @without.apply(this, @completed())

  # We keep the toDos in sequential order, despite being saved by unordered
  # GUID in the database. This generate the next order number for new items
  nextOrder: -> unless @length then 1 else @last().get('order') + 1

  # toDos are sorted by their original insertion order.
  comparator: (task) -> task.get 'order'

app.tasks = new TaskList()
