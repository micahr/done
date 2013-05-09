Todos = new Meteor.Collection("todos")

Todos.allow(
  insert: (userId, todo) ->
    return userId == todo.owner
  update: (userId, todo, fields, modifier) ->
    if userId != todo.owner
      false
    allowed = ["text", "date", "done"]
    if _.difference(fields, allowed).length
      false
    true

  remove: (userId, todo) ->
    return userId == todo.owner
)

Meteor.methods({
  createTodo: (options) ->
    if !(typeof options.text == "string" and
      options.date instanceof Date)
        throw new Meteor.Error(400, "Required parameter missing")
    if options.text.length > 100
      throw new Meteor.Error(413, "Text too long")
    if !@userId
      throw new Meteor.Error(403, "You must be logged in")

    return Todos.insert(
      owner: @userId
      text: options.text
      date: options.date
      done: options.done
    )

  complete: (todoId) ->
    todo = Todos.findOne(todoId)
    if !todo or @userId != todo.owner
      throw new Meteor.Error(404, "No such Todo")
    Todos.update(todoId, $set: done: true)
  uncomplete: (todoId) ->
    todo = Todos.findOne(todoId)
    if !todo or @userId != todo.owner
      throw new Meteor.Error(404, "No such Todo")
    Todos.update(todoId, $set: done: false)
  }
)