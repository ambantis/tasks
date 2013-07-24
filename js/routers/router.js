// Generated by CoffeeScript 1.6.3
(function() {
  var Workspace, app;

  if (window.app == null) {
    window.app = {};
  }

  app = window.app;

  Workspace = Backbone.Router.extend({
    routes: {
      '*filter': 'setFilter'
    },
    setFilter: function(param) {
      if (param) {
        param = param.trim();
      }
      app.taskFilter = param || '';
      return app.tasks.trigger('filter');
    }
  });

  app.todoRouter = new Workspace();

  Backbone.history.start();

}).call(this);

/*
//@ sourceMappingURL=router.map
*/