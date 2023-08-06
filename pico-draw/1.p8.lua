--  drawing screen

function init_drawing()
	mode = make_cursor(3)

	-- line drawing
	line_start_x = nil
	line_start_y = nil

	-- fill tool
	replace_color = nil
	fill_start_x = nil
	fill_start_y = nil

	dx_val = {0, 1, 0, -1}
	dy_val = {-1, 0, 1, 0}

	debug = false
    reset_field()
end

function update_drawing()
	in_bounds = is_inbounds(m_x, m_y)

	-- if left click or 🅾️
	-- set color on field
	if lmb and mode.selected == 0 and in_bounds then
		field[m_x][m_y] = cur_color.selected
	end

	if lmbp and in_bounds then
		if mode.selected == 1 then
			if (line_start_x == nil) then
				line_start_x = m_x
				line_start_y = m_y

				printh("set start to " .. line_start_x .. ", " .. line_start_y)
			else
				draw_line(line_start_x, line_start_y, m_x, m_y)
				printh("set end to " .. m_x .. ", " .. m_y)

				line_start_x = nil
				line_start_y = nil
			end
		elseif mode.selected == 2 then
			flood_fill(m_x, m_y, field[m_x][m_y])
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

	if btnp(➡️) then
		debug = not debug
	end

	if btnp(🅾️) then
		mode.add(1)
	end
end

function draw_drawing()
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

	if debug then
		print(m_x .. ", " .. m_y, 0, 0)
		print("mode = " .. mode.selected, 0, 8)
	end
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

function is_inbounds(x, y)
	return x > 0 and x < 65 and y > 0 and y < 65
end

function find_adjacent(x, y, dir)
	local this = {}
	this.x = x + dx_val[dir]
	this.y = y + dy_val[dir]

	if is_inbounds(this.x, this.y) then
		return this
	else
		return false
	end
end

-- implementation of bresenham's line algorithm
-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

function plot_line_low(x0, y0, x1, y1)
    local dx = x1 - x0
    local dy = y1 - y0
    local yi = 1
    if dy < 0 then
        yi = -1
        dy = -dy
    end
    local D = 2 * dy - dx
    local y = y0

    for x = x0, x1, 1 do
		field[x][y] = cur_color.selected
        if D > 0 then
            y = y + yi
            D = D + 2 * (dy - dx)
        else
            D = D + 2 * dy
        end
	end
end

function plot_line_high(x0, y0, x1, y1)
    local dx = x1 - x0
    local dy = y1 - y0
    local xi = 1
    if dx < 0 then
        xi = -1
        dx = -dx
    end
    local D = 2 * dx - dy
    local x = x0

    for y = y0, y1, 1 do
		field[x][y] = cur_color.selected
        if D > 0 then
            x = x + xi
            D = D + 2 * (dx - dy)
        else
            D = D + 2 * dx
        end
	end
end

function draw_line(x0, y0, x1, y1)
	if abs(y1 - y0) < abs(x1 - x0) then
        if x0 > x1 then
            plot_line_low(x1, y1, x0, y0)
        else
            plot_line_low(x0, y0, x1, y1)
        end
    else
        if y0 > y1 then
            plot_line_high(x1, y1, x0, y0)
        else
            plot_line_high(x0, y0, x1, y1)
        end
    end
end

-- implementation of flood fill
-- https://en.wikipedia.org/wiki/Flood_fill
-- adapted from https://github.com/Rayquaza01/minesweeper/blob/1edfc1f061032966f668cb0baf0b1f6ec6f63197/minesweeper/3.p8.lua#L112

function flood_fill(x, y, color)
	for d = 1, 4, 1 do
		adj = find_adjacent(x, y, d)
		if adj then
			if field[adj.x][adj.y] == color then
				field[adj.x][adj.y] = cur_color.selected
				flood_fill(adj.x, adj.y, color)
			end
		end
	end
end
