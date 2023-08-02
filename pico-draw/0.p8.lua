function _init()
	cls()
	poke(0x5f2c, 3) -- 64x64
	poke(0x5f2d, 1) -- mouse
	
	-- cursor class for current color
	cur_color = make_cursor(16)
	-- initialize field
	reset_field()
end

function _update()
	-- update all mouse globals
	mouse_update()

	-- if left click or 🅾️
	-- set color on field
	if btn(🅾️) or lmb then
		-- bounds checking
		if m_x > 0 and m_x < 65 and m_y > 0 and m_y < 65 then
			field[m_x][m_y] = cur_color.selected
		end
	end
	
	-- if right click or ❎ (press)
	-- then increment current color
	if btnp(❎) or rmbp then
		cur_color.add(1)
	end

	-- if middle click or ⬇️ (press)
	-- reset field
	if btnp(⬇️) or mmbp then
		reset_field()
	end
end

function _draw()
	cls()	
	--map()

	-- iterate over field
	for i = 1, #field, 1 do
		for j = 1, #field, 1 do
			-- set pixel to color
			pset(i - 1, j - 1, field[i][j])
		end
	end
	
	-- draw mouse cursor
	spr(4, m_x, m_y)
	-- draw current color indicator
	pset(m_x, m_y, cur_color.selected)
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
	lmb = band(mstats, 1) == 1
	rmb = band(mstats, 2) == 2
	mmb = band(mstats, 4) == 4
	
	lmbp = not lmb_prev and lmb
	mmbp = not mmb_prev and mmb
	rmbp = not rmb_prev and rmb
end
