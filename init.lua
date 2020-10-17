local default_skin = ts_skins.build_skin_texture(ts_skins.get_body_features(""), ts_skins.get_clothing_textures(""))
local priv = minetest.settings:get("ts_skins_dummies.priv") or "server"

minetest.register_entity("ts_skins_dummies:dummy", {
	initial_properties = {
		visual = "mesh",
		mesh = "3d_armor_character.b3d",
		textures = {
			default_skin,
			"3d_armor_trans.png",
			"3d_armor_trans.png",
		},
		collisionbox = {-0.2, 0.0, -0.2, 0.2, 1.7, 0.2},
	},

	on_punch = function(self, player)
		local name = player:get_player_name()
		if minetest.check_player_privs(name, priv) then
			if player:get_player_control().sneak then
				self.object:remove()
			else
				minetest.chat_send_player(name, "Use Sneak+Punch to remove the dummy or Sneak+Rightclick to set the skin.")
			end
		end
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		local data = minetest.deserialize(staticdata) or {}
		if data.textures and type(data.textures) == "table" then
			local props = self.object:get_properties()
			props.textures = data.textures
			self.object:set_properties(props)
		end
	end,

	on_rightclick = function(self, player)
		local name = player:get_player_name()
		if minetest.check_player_privs(name, priv) then
			if player:get_player_control().sneak then
				local props = self.object:get_properties()
				props.textures = {
					armor.textures[name].skin,
					armor.textures[name].armor,
					armor.textures[name].wielditem,
				}
				self.object:set_properties(props)
			else
				minetest.chat_send_player(name, "Use Sneak+Punch to remove the dummy or Sneak+Rightclick to set the skin.")
			end
		end
	end,

	get_staticdata = function(self)
		return minetest.serialize({
			textures = self.object:get_properties().textures
		})
	end
})


minetest.register_chatcommand("spawndummy", {
	params = "",
	description = "Spawn a Dummy",
	privs = {[priv] = true},
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local look_dir = player:get_look_dir()
		local p1 = vector.add(player:get_pos(), player:get_eye_offset())
		p1.y = p1.y + player:get_properties().eye_height
		local p2 = vector.add(p1, vector.multiply(look_dir, 7))
		local raycast = minetest.raycast(p1, p2, false)
		local pointed_thing = raycast:next()
		if not pointed_thing then
			minetest.chat_send_player(name, "No position found! Point at a node when entering this command to place a dummy.")
			return
		end
		local pos = pointed_thing.intersection_point

		local dummy = minetest.add_entity(pos, "ts_skins_dummies:dummy", minetest.serialize({
			textures = {
				armor.textures[name].skin,
				armor.textures[name].armor,
				armor.textures[name].wielditem,
			}
		}))

		if dummy then
			dummy:set_yaw(player:get_look_horizontal() + math.pi)
		end
	end
})