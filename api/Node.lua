local Node = {}

function Node.current()
   local field = require("internal.global.field")
   return field.node
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

local function create_node(node)
   node.children = node.children or {}
   node.events = node.events or {}
   return node
end

function Node.add(target, proto)
   local node = create_node(proto)
   node.parent = target

   table.insert(target.children, node)
   return node
end

return Node
