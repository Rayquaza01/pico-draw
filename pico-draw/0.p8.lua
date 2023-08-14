function _init()
	printh("starting app...")

	cls()
	poke(0x5f2c, 3) -- 64x64
	poke(0x5f2d, 1) -- mouse

	gamestate = 0

	-- cursor class for current color
	cur_color = make_cursor(16)

	-- initialize field
	init_drawing()
end

function _update()
	-- update all mouse globals
	mouse_update()

	if gamestate == 0 then
		update_drawing()
	elseif gamestate == 1 then
		update_menu()
	elseif gamestate == 2 then
		update_credits()
	end

end

function _draw()
	cls()

	if gamestate == 0 then
		draw_drawing()
	elseif gamestate == 1 then
		draw_menu()
	elseif gamestate == 2 then
		draw_credits()
	end
end

function make_cursor(n)
	local this = {}
	this.selected = 0
	this.length = n

	-- increase position, roll over if passed length
	this.add = function(d)
		this.selected += d
		this.selected %= this.length
	end

	return this
end

function make_countdown(n)
	local this = {}
	-- maximum value of countdown
	this.max = n
	-- current value
	this.val = n
	-- is enabled
	this.enabled = true

	-- subtract s from current value
	this.subtract = function(s)
		if (this.enabled) this.val -= s
	end

	-- reset current value to max
	this.reset = function()
		this.val = this.max
	end

	-- if current value less than 0, reset countdown
	-- and return true
	this.is_finished = function()
		if (this.val <= 0) then
			this.reset()
			return true
		end
		return false
	end

	return this
end


function reset_field()
	field = {}
	for i = 1, 64, 1 do
		field[i] = {}
		for j = 1, 64, 1 do
			-- white default
			field[i][j] = 7
		end
	end
end

function mouse_update()
	mstats = stat(34)
	lmb_prev = lmb
	mmb_prev = mmb
	rmb_prev = rmb
	m_x = stat(32)
	m_y = stat(33)

	m_cell_x = flr(m_x / 8)
	m_cell_y = flr(m_y / 8)
	lmb = (mstats & 1) == 1
	rmb = (mstats & 2) == 2
	mmb = (mstats & 4) == 4

	lmbp = not lmb_prev and lmb
	mmbp = not mmb_prev and mmb
	rmbp = not rmb_prev and rmb
end

function change_game_state(v)
	gamestate = v
end

function pop(stack)
	local v = stack[#stack]
	stack[#stack] = nil
	return v
end
