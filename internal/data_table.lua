local CodeGenerator = require("api.CodeGenerator")
local Log = require ("api.Log")
local env = require ("internal.env")
local fs = require("util.fs")

local data_table = class.class("data_table")

local function script_path()
   local frame = 1
   local going = true
   local str
   local info

   while going do
      info = debug.getinfo(frame, "S")
      if not info then
         return nil
      end
      str = info.source:sub(2)
      if str ~= "./internal/data.lua" then
         going = false
      end
      frame = frame + 1
   end
   return str, info.linedefined
end

function data_table:error(mes, ...)
   local file, line = script_path()
   mes = string.format(mes, ...)
   table.insert(self.errors,
                {
                   file = file,
                   line = line,
                   level = "error",
                   message = mes,
                }
   )
   error("data: " .. mes .. inspect(self))
end

function data_table:init()
    rawset(self, "errors", {})
    rawset(self, "fallbacks", {})

    rawset(self, "inner", {})
    rawset(self, "index", {})
    rawset(self, "schemas", {})
    rawset(self, "metatables", {})
    rawset(self, "generates", {})
    rawset(self, "strict", false)
end

function data_table:clear()
   self.inner = {}
   self.index = {}
   self.schemas = {}
   self.metatables = {}

   self.errors = {}
   self.fallbacks = {}
end

function data_table:types(kind)
   local keys = table.keys(self.inner)
   if kind == "template" then
      -- Return only types with any "fields" declared.
      local pred = function(id)
         return #self.schemas[id].fields > 0
      end
      return fun.iter(keys):filter(pred):to_list()
   end
   return keys
end

local function add_index_field(self, dat, _type, field)
   if type(field) == "string" then field = {field} end
   for _, v in ipairs(field) do
      local index_key = dat[v]

      -- NOTE: If the field is missing, it is skipped for indexing.
      -- However, if it is specified and not unique, then an error is
      -- raised.
      if index_key ~= nil then
         local key = "by_" .. v
         self.index[_type][key] = self.index[_type][key] or {}

         local exist = self.index[_type][key][index_key]
         if exist ~= nil then
            self:error(string.format("self.index value on '%s' is not unique: '%s:%s = %s'", _type, v, index_key, exist._id))
         else
            self.index[_type][key][index_key] = dat
         end
      end
   end
end

local function remove_index_field(self, dat, _type, field)
   if type(field) == "string" then field = {field} end
   for _, v in ipairs(field) do
      local index_key = dat[v]

      if index_key ~= nil then
         local key = "by_" .. v
         self.index[_type][key] = self.index[_type][key] or {}

         self.index[_type][key][index_key] = nil
      end
   end
end

function data_table:add_index(_type, field)
   if not self.schemas[_type] then
      return
   end

   if self.schemas[_type].indexes[field] then
      return
   end

   -- TODO: verify is a valid field for this type
   self.schemas[_type].indexes[field] = true

   for _, dat in self[_type]:iter() do
      add_index_field(self, dat, _type, field)
   end
end

local function is_valid_ident(name)
   return string.match(name, "^[_a-z][_a-z0-9]*$")
end

function data_table:add_type(schema, params)
   schema.fields = schema.fields or {}
   schema.fallbacks = schema.fallbacks or {}

   params = params or {}

   if not is_valid_ident(schema.name) then
      self:error("'%s' is not a valid identifier (must consist of lowercase letters, numbers and underscores only, cannot start with a number)", schema.name)
      return nil
   end

   local mod_name, loc = env.find_calling_mod()
   local _type = mod_name .. "." .. schema.name

   if env.is_hotloading() and self.schemas[_type] then
      Log.debug("In-place update of type %s", _type)

      schema.indexes = self.schemas[_type].indexes
      if loc then
         schema._defined_in = {
            relative = fs.normalize(loc.short_src),
            line = loc.lastlinedefined
         }
      else
         schema._defined_in = {
            relative = ".",
            line = 0
         }
      end
      table.replace_with(self.schemas[_type], schema)
      return
   end

   schema.indexes = {}

   local metatable = params.interface or {}
   metatable._type = _type

   local generate = params.generates or nil

   if loc then
      schema._defined_in = {
         relative = fs.normalize(loc.short_src),
         line = loc.lastlinedefined
      }
   else
      schema._defined_in = {
         relative = ".",
         line = 0
      }
   end

   self.inner[_type] = {}
   self.index[_type] = {}
   self.schemas[_type] = schema
   self.metatables[_type] = metatable
   self.generates[_type] = generate

   local fallbacks = table.deepcopy(schema.fallbacks)
   for _, field in ipairs(schema.fields) do
      fallbacks[field.name] = field.default
   end
   self.fallbacks[_type] = fallbacks
end

-- TODO: metatable indexing could create a system for indexing
-- sandboxed properties partitioned by each mod. For example the
-- underlying table would contain { base = {...}, mod = {...} } and
-- indexing obj.field might actually self.index obj.base.field.
function data_table:extend_type(type_id, delta)
end

function data_table:run_all_edits()
end

function data_table:run_edits_for(_type, _id)
end

local function update_docs(dat, _schema, loc, is_hotloading)
end

function data_table:replace(dat)
   local mod_name = env.find_calling_mod()
   local _id = dat._id
   local _type = dat._type
   local full_id = mod_name .. "." .. _id

   if not self.inner[_type][full_id]  then
      self:error("ID does not exist for type '%s': '%s'", _type, full_id)
   end

   Log.debug("Replacing %s:%s", _type, full_id)
   self.inner[_type][full_id] = nil
   self:add(dat)
end

function data_table:add(dat)
   local mod_name, loc = env.find_calling_mod()

   local _id = dat._id
   local _type = dat._type

   if not (string.nonempty(_id) and string.nonempty(_type)) then
      self:error("Missing _id (%s) or _type (%s)", tostring(_id), tostring(_type))
      return nil
   end

   if not is_valid_ident(_id) then
      _ppr(dat)
      self:error("'%s' is not a valid identifier (must consist of lowercase letters, numbers and underscores only, cannot start with a number)", _id)
      return nil
   end

   local _schema = self.schemas[_type]

   if _schema == nil then
      self:error("No type registered for " .. _type)
      return nil
   end

   local failed = false

   if self.strict and failed then return nil end

   local full_id = mod_name .. "." .. _id

   if self.inner[_type][full_id] ~= nil then
      if env.is_hotloading() then
         Log.debug("In-place update of %s:%s", _type, full_id)
         dat._id = full_id

         -- local Event = require("api.Event")
         -- Event.trigger("base.before_hotload_prototype", {old=self.inner[_type][full_id], new=dat})

         table.replace_with(self.inner[_type][full_id], dat)
         self:run_edits_for(_type, full_id)

         for field, _ in pairs(_schema.indexes) do
            remove_index_field(self, dat, _type, field)
            add_index_field(self, dat, _type, field)
         end

         -- Event.trigger("base.on_hotload_prototype", {entry=dat})

         update_docs(dat, _schema, loc, true)

         return dat
      else
         Log.error("ID is already taken on type '%s': '%s'", _type, full_id)
         -- self:error(string.format("ID is already taken on type '%s': '%s'", _type, full_id))
         return nil
      end
   end

   -- TODO fallbacks and prototype_fallbacks should be separate
   self.inner[_type][full_id] = dat

   for field, _ in pairs(_schema.indexes) do
      add_index_field(self, dat, _type, field)
   end

   dat._id = full_id

   update_docs(dat, _schema, loc)

   return dat
end

function data_table:make_template(_type, opts)
   if not self.schemas[_type] then
      error(("No such type: '%s'"):format(_type))
   end

   opts = opts or {}
   opts.scope = opts.scope or "template"
   if opts.comments == nil then
      opts.comments = false
   end
   if opts.snippets == nil then
      opts.snippets = false
   end

   local gen = CodeGenerator:new()
   local snippet_index = 1

   gen:write("data:add ")
   gen:write_table_start()
   gen:write_key_value("_type", _type)

   local _id = "default"
   if opts.snippets then
      _id = ("${%d:%s}"):format(snippet_index, _id)
      snippet_index = snippet_index + 1
   end
   gen:write_key_value("_id", _id)

   local first = true
   local did_comment
   local write_fields = function(pred)
      for _, field in ipairs(self.schemas[_type].fields) do
         local is_in_scope = opts.scope == "all" or field.template
         local do_write = pred(field) and is_in_scope
         if do_write then
            if first then
               gen:tabify()
               first = false
            elseif did_comment then
               gen:tabify()
            end
            local do_comment = opts.comments and field.doc
            if do_comment then
               gen:tabify()
               gen:write_comment(field.doc, {type="docstring"})
               local ty = field.type
               if ty == nil and field.default ~= nil then
                  ty = type(field.default)
               end
               if ty then
                  gen:write_comment(("@type %s"):format(ty), {type="docstring"})
               end
            end

            local value = field.default
            if opts.snippets then
               if type(value) == "string" then
                  value = string.format("${%d:%s}", snippet_index, value)
               else
                  local gen2 = CodeGenerator:new()
                  gen2:write_value(value)
                  value = tostring(gen2):gsub("([}])", "\\%1")
                  value = string.format("${%d:%s}", snippet_index, value)
                  value = CodeGenerator.gen_literal(value)
               end
               snippet_index = snippet_index + 1
            end
            gen:write_key_value(field.name, value)

            did_comment = do_comment
         end
      end
   end

   -- group fields with documentation first
   write_fields(function(field) return field.doc ~= nil end)
   write_fields(function(field) return field.doc == nil end)

   if opts.scope == "optional_commented" then
      local first = true
      local write_fields = function(pred)
         local prev_comment
         for _, field in ipairs(self.schemas[_type].fields) do
            local do_comment = true
            local do_write = pred(field) and opts.scope == "optional_commented"
                and not field.default and not field.template
            if do_write then
               if first then
                  gen:tabify()
                  gen:tabify()
                  gen:tabify()
                  first = false
               end
               do_comment = opts.comments and field.doc
               if do_comment then
                  if not prev_comment then
                     gen:tabify()
                  end
                  gen:write_comment(field.doc, {type="docstring"})
                  local ty = field.type
                  if ty == nil and field.default ~= nil then
                     ty = type(field.default)
                  end
                  if ty then
                     gen:write_comment(("@type %s"):format(ty), {type="docstring"})
                  end
               end
               local gen2 = CodeGenerator:new()
               gen2:write_key_value(field.name, field.default)
               gen:write_comment(tostring(gen2))

               if do_comment then
                  gen:tabify()
               end
            end
            prev_comment = do_comment
         end
      end

      -- group fields with documentation first
      write_fields(function(field) return field.doc ~= nil end)
      write_fields(function(field) return field.doc == nil end)
   end

   gen:write_table_end()
   if opts.snippets then
      gen:write("${0}")
   end

   return tostring(gen)
end

function data_table:iter()
   return fun.iter(table.keys(self.schemas)):map(function(ty) return ty, data[ty] end)
end

function data_table:add_multi(_type, list)
   for _, dat in ipairs(list) do
      dat._type = _type
      self:add(dat)
   end
end

function data_table:has_type(_type)
   return self.inner[_type] ~= nil
end

local proxy = class.class("proxy")

function proxy:init(_type, data)
   rawset(self, "_type", _type)
   rawset(self, "data", data)
end

function proxy:__newindex(k, v)
end

function proxy:find_by(index_field, value)
   if not self.data.index[self._type] then
      error("Unknown type " .. self._type)
   end
   if self.data.index[self._type]["by_" .. index_field] ~= nil then
      return self.data.index[self._type]["by_" .. index_field][value]
   end

   return nil
end

function proxy:__index(k)
   local exist = rawget(proxy, k)
   if exist then return exist end

   if k == "_defined_in" then
      return self.data.schemas[self._type]._defined_in
   end

   if k == "on_document" then
      return self.data.schemas[self._type].on_document
   end

   if k == "doc" then
      return self.data.schemas[self._type].doc
   end

   local _type = rawget(self, "_type")
   local for_type = rawget(self.data.inner, _type)
   if for_type == nil then
      return nil
   end

   -- Permit substituting an instance of a data type if it is passed
   -- in instead of a string key.
   if type(k) == "table"
      and k._type == _type
      and for_type[k._id]
   then
      return k
   end

   return for_type[k]
end

function proxy:interface()
   return self.data.metatables[self._type]
end

function proxy:ensure(k)
   local it = self[k]
   if it == nil then
      error(string.format("No instance of %s with ID %s was found.", self._type, k))
   end
   return it
end

local function iter(state, prev_index)
   if state.iter == nil then
      return nil
   end

   local next_index, dat = state.iter(state.state, prev_index)

   if next_index == nil then
      return nil
   end

   return next_index, dat
end

function proxy:iter()
   local inner_iter, inner_state, inner_index = pairs(self.data.inner[self._type])
   return fun.wrap(iter, {iter=inner_iter,state=inner_state}, inner_index)
end

function proxy:print()
   local list = {}
   for _, v in self:iter() do
      list[#list+1] = { v._id }
   end
   return table.print(list, { header = { "ID" }, sort = 1 })
end

function data_table:__index(k)
    -- This always returns a table instead of nil so
    -- that references to data type tables can be
    -- populated later, after mods have finished
    -- loading. As an example, if this returned nil if
    -- a type was nonexistent, it would be necessary to
    -- initialize things like the sound manager only
    -- after mods have been loaded.
    if data_table[k] then return data_table[k] end
    return proxy:new(k, self)
end

function data_table:__newindex(k, v)
end

return data_table
