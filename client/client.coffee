Meteor.subscribe("todos")

# Setup query for Todos that are before Today, update them to be today
oldTodosQuery = Todos.find(
  date:
    {$lt: moment().startOf("day").toDate()}
  done: false
)
oldTodosQuery.observe(added: (item) ->
  Todos.update(item._id, $set: date: new Date())
)

Session.setDefault("first_day", new Date())

Template.todos_main.days = ->
  moment(Session.get("first_day")).add("days",d) for d in [0..4]

Template.todos_main.events = {
  'click .left.arrow': ->
    previousDay()
  'click .right.arrow': ->
    nextDay()
}

previousDay = ->
  Session.set("first_day", moment(Session.get("first_day")).subtract("days", 1).toDate())
nextDay = ->
  Session.set("first_day", moment(Session.get("first_day")).add("days", 1).toDate())
previousWeek = ->
  Session.set("first_day", moment(Session.get("first_day")).subtract("days", 5).toDate())
nextWeek = ->
  Session.set("first_day", moment(Session.get("first_day")).add("days", 5).toDate())


Template.day.rendered = ->
  $(@firstNode).find("ul").sortable
    connectWith: '.connectedSortable'
    distance: 15
    receive: (event, ui) ->
      newMoment = moment.unix($(@).parent().attr("data-moment"))
      Todos.update(ui.item[0].id, {
        $set:
          date: newMoment.toDate()})
      $(ui.item[0]).remove()

Template.day.todos = ->
  Todos.find(
    date:
      $gte: this.startOf("day").toDate()
      $lte: moment(this).endOf("day").toDate()
  )

Template.day.events = {
  'dblclick ul': (event, template) ->
    if !moment(template.data).isBefore(moment(), "day")
      Todos.insert({
        owner: Meteor.userId()
        text: ""
        date: template.data.toDate()
        done: false
      }, (err, id) ->
        startEditing($("#" + id))
      )

  'click .todo-item': (event) ->
    # Toggle an items' "doneness"
    if $(event.target).hasClass("done")
      Todos.update($(event.target).attr('data-id'), $set: done: false)
    else
      Todos.update($(event.target).attr('data-id'), $set: done: true)
  'dblclick .todo-item': (event) ->
    # Stop dblclick event from bubbling up to the UL
    event.stopPropagation()
    startEditing(event.target)
  'mouseenter .todo-item': (event) ->
    $(event.target).append("<i class='icon-pencil'></i>")
  'mouseleave .todo-item': (event) ->
    $(event.target).find(".icon-pencil").remove()
  'click .icon-pencil': (event) ->
    console.log event
    startEditing($("#" + $(event.target).parent().attr("data-id")))
  'blur': ->
    cancelEditingItem()
  'keyup': (event) ->
    if event.which == 27
      cancelEditingItem()
    if event.which == 13
      $(".editing").each((index, item) ->
        newText = $(item).find("input").val()
        if (newText != "")
          Todos.update($(item).attr("data-id"), $set: text: newText)
          $(item).html(newText)
          $(item).attr("data-original", newText)
          $(item).removeClass("editing")
        else
          Todos.remove($(item).attr("data-id"))
      )
}

Template.day.day_fmt = (mmnt) ->
  mmnt.format("ddd").toUpperCase()
Template.day.mon_fmt = (mmnt) ->
  mmnt.format("MMM").toUpperCase()
Template.day.date_fmt = (mmnt) ->
  mmnt.format("DD")
Template.day.isActive = (mmnt) ->
  return moment(mmnt).isSame(moment(),"day")

cancelEditingItem = ->
  $(".editing").each((index, item) ->
    if ($(item).find("input").val() == "" && $(item).attr("data-original") == "")
      Todos.remove($(item).attr("data-id"))
    else
      $(item).html($(item).attr("data-original"))
      $(item).removeClass("editing")
  )

startEditing = (target) ->
  $(target).addClass("editing")
  $(target).html("<input type='text' class='span2' value='"+$(target).text()+"' />")
  $(target).find("input").focus()
