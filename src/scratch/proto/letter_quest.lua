local Game = require("api.Game")
local Node = require("api.Node")
local Quest = require("api.Quest")
local ShopNode = {}
local BeingNode = {}

local function letter_receive_item(node, item)
   if item.quest.owner == node then
      Game.push_subdialog {
         "...",
         "Thanks! I am indebted to you."
      }
      BeingNode.mod_relationship(node, Node.player(), 100)
      Game.earn_money(1000)
      Quest.complete(item.quest)
      return true
   end

   return false
end

local function letter_begin(letter)
   local root = Node.area_root()

   local residence = Node.pick(root, "!residence") -- compo_residence
   local owner = residence.owner
   Node.move(owner, root)
   owner.move_restriction = { root = residence }

   local category = "toy"
   local shop = ShopNode.find_shop(root, "toy")
   local item = Node.generate(".toy")
   item.no_remove = true
   ShopNode.add_to_inventory(shop, item)

   letter.text = {
      "I'm wanting a present for myself.",
      "Getting kind of bored without it.",
      "Anyway, it looks like this:",
      { node = item },
      "Please help me find it.",
      "    - Signed, " .. owner.name,
      "    " .. residence.name .. ", " .. residence.parent.name
   }

   local quest = {
      shop = shop,
      item = item,
      owner = owner
   }

   table.insert(item.quests, quest)
   table.insert(owner.dialog_choices, { "base.found_item"})
   Node.add_event(owner, "on_receive_item", letter_receive_item)

   return quest
end

local function letter_end(quest)
   table.remove(quest.item.quests, quest)
   quest.owner.move_restriction = nil
   if ShopNode.has_item(quest.shop, quest.item) then
      ShopNode.remove_from_inventory(quest.shop, quest.item)
   end
end
