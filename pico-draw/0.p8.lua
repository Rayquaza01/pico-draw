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
	end

end

function _draw()
	cls()

	if gamestate == 0 then
		draw_drawing()
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
