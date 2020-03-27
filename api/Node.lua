local Gui = require("api.Gui")
local Node = {}

function Node.current()
   local field = require("internal.global.field")
   return field.node
end

function Node.player()
   return save.base.player
end

function Node.goto_node(node)
   local field = require("internal.global.field")
   field:goto_node(node)
end

function Node.activate(node)
   if node.compo_activator then
      node:on_activate(node)
      return
   end

   if node.compo_location then
      Gui.play_sound("base.pop2")
      Node.goto_node(node)
   end

   if node.compo_item then
   end
end

function Node.proc(node, event_id, ...)
   local events = node.events or {}
   for _, id in ipairs(events[event_id] or {}) do
      data["base.event"]:ensure(id).callback(node, ...)
   end
end

function Node.children(root)
   return fun.iter(root.children)
end

function Node.clear(target)
   for _, v in ipairs(target.children) do
      target.parent = nil
   end
   target.children = {}
end

function Node.create(node, parent)
   node.children = node.children or {}
   node.events = node.events or {}
   node.parent = parent
   Node.proc(node, "on_create")
   return node
end

function Node.add(target, proto)
   local node = Node.create(proto, target)

   table.insert(target.children, node)
   return node
end

function Node.in_field()
   return Node.children(Node.current()):filter(function(node)
         return node.visible_in == nil or node.visible_in == "field"
                                              end)
end

return Node
