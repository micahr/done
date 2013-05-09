

Meteor.startup ->
  if Todos.find().count() == 0
    data = [
      {
        text: "Old Item - Done"
        date: moment().subtract("days", 3).toDate()
        done: true,
        owner: "hJTY6dkeipZzp937Z"},
      {
        text: "Old Item"
        date: moment().subtract("days", 3).toDate()
        done: false
        owner: "hJTY6dkeipZzp937Z"},
      {
        text: "Plan Rome Trip"
        date: moment().toDate()
        done: false
        owner: "hJTY6dkeipZzp937Z"},
      {
        text: "Get Pasties"
        date: moment().add("days", 3).toDate()
        done: false
        owner: "hJTY6dkeipZzp937Z"},
      {
        text: "Eat Pie"
        date: moment().add("days", 2).toDate()
        done: false
        owner: "hJTY6dkeipZzp937Z"}
    ]

    for item in data
      Todos.insert(item)