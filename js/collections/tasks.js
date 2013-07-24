// Generated by CoffeeScript 1.6.3
(function() {
  var TaskList, app;

  if (window.app == null) {
    window.app = {};
  }

  app = window.app;

  TaskList = Backbone.Collection.extend({
    model: app.Task,
    localStorage: new Backbone.LocalStorage('tasks-backbone'),
    completed: function() {
      return this.filter(function(task) {
        return task.get('completed');
      });
    },
    remaining: function() {
      return this.without.apply(this, this.completed());
    },
    nextOrder: function() {
      if (!this.length) {
        return 1;
      } else {
        return this.last().get('order') + 1;
      }
    },
    comparator: function(task) {
      return task.get('order');
    }
  });

  app.tasks = new TaskList();

}).call(this);

/*
//@ sourceMappingURL=tasks.map
*/
