--  drawing screen

function init_drawing()
	mode = make_cursor(5)

	-- line drawing
	line_start_x = nil
	line_start_y = nil

	-- fill tool
	replace_color = nil
	fill_start_x = nil
	fill_start_y = nil

	-- circle tool
	circle_center_x = nil
	circle_center_y = nil

	dx_val = {0, 1, 0, -1}
	dy_val = {-1, 0, 1, 0}

	draw_speed = 5
	draw_speed_line = 1
	draw_speed_circle = 1
	draw_speed_fill = 5

	coroutines = {}

	debug = false
    reset_field()
end

function update_drawing()
	in_bounds = is_inbounds(m_x, m_y)

	-- continue our coroutines
	for c in all(coroutines) do
		if costatus(c) == "dead" then
			del(coroutines, c)
		else
			coresume(c)
		end
	end

	-- if left click or 🅾️
	-- set color on field
	if lmb and mode.selected == 0 and in_bounds then
		set_field(m_x, m_y, cur_color.selected)
	end

	if lmbp and in_bounds then
		if mode.selected == 1 then
			if (line_start_x == nil) then
				line_start_x = m_x
				line_start_y = m_y

				printh("set line start to " .. line_start_x .. ", " .. line_start_y)
			else
				local c = cocreate(draw_line)
				coresume(c, line_start_x, line_start_y, m_x, m_y, cur_color.selected)
				add(coroutines, c)
				printh("set line end to " .. m_x .. ", " .. m_y)

				line_start_x = nil
				line_start_y = nil
			end
		elseif mode.selected == 2 then
			replace_color = field[m_x][m_y]
			-- do not flood fill if trying to replace color with itself!
			-- it wouldn't have any effect, and also causes infinite recursion
			if not (replace_color == cur_color.selected) then
				local fill_cor = cocreate(flood_fill)
				coresume(fill_cor, m_x, m_y, replace_color, cur_color.selected)
				add(coroutines, fill_cor)
			end
		elseif mode.selected == 3 then
			if (circle_center_x == nil) then
				circle_center_x = m_x
				circle_center_y = m_y

				printh("set circle center to " .. circle_center_x .. ", " .. circle_center_y)
			else
				-- get radius of circle using distance formula
				-- sqrt((x - x0) ^ 2 + (y - y0) ^ 2))
				radius = flr(sqrt((m_x - circle_center_x) ^ 2 + (m_y - circle_center_y) ^ 2))

				local c = cocreate(draw_circle)
				coresume(c, circle_center_x, circle_center_y, radius, cur_color.selected)
				add(coroutines, c)
				printh("set circle radius to " .. radius)

				circle_center_x = nil
				circle_center_y = nil
			end
		elseif mode.selected == 4 then
			cur_color.selected = field[m_x][m_y]
			mode.selected = 0
		end
	end

	-- if right click or ❎ (press)
	-- then increment current color
	if btnp(❎) or rmbp then
		cur_color.add(1)
	end

	if btnp(🅾️) then
		cur_color.add(-1)
	end

	-- if middle click or ⬇️ (press)
	-- reset field
	if mmbp then
		reset_field()
	end

	if btnp(⬆️) then
		debug = not debug
	end

	if btnp(⬇️) then
		gamestate = 1
	end

	if btnp(➡️) then
		mode.add(1)
	end

	if btnp(⬅️) then
		mode.add(-1)
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
	spr(1 + mode.selected, m_x - 1, m_y - 1)
	-- draw current color indicator
	pset(m_x - 1, m_y - 1, cur_color.selected)

	if debug then
		print(m_x .. ", " .. m_y, 0, 0)
		print("mode = " .. mode.selected, 0, 8)
		print("color = " .. cur_color.selected, 0, 16)
	end
end

function set_field(x, y, val)
	if is_inbounds(x, y) then
		field[x][y] = val
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

function plot_line_low(x0, y0, x1, y1, line_color)
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
		set_field(x, y, line_color)
        if D > 0 then
            y = y + yi
            D = D + 2 * (dy - dx)
        else
            D = D + 2 * dy
        end

		if line_speed.is_finished() then
			line_speed.reset()
			yield()
		end

		line_speed.subtract(1)
	end
end

function plot_line_high(x0, y0, x1, y1, line_color)
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
		set_field(x, y, line_color)
        if D > 0 then
            x = x + xi
            D = D + 2 * (dx - dy)
        else
            D = D + 2 * dx
        end

		if line_speed.is_finished() then
			line_speed.reset()
			yield()
		end

		line_speed.subtract(1)
	end
end

function draw_line(x0, y0, x1, y1, line_color)
	line_speed = make_countdown(draw_speed_line)

	if abs(y1 - y0) < abs(x1 - x0) then
        if x0 > x1 then
            plot_line_low(x1, y1, x0, y0, line_color)
        else
            plot_line_low(x0, y0, x1, y1, line_color)
        end
    else
        if y0 > y1 then
            plot_line_high(x1, y1, x0, y0, line_color)
        else
            plot_line_high(x0, y0, x1, y1, line_color)
        end
    end
end

-- implementation of flood fill
-- https://en.wikipedia.org/wiki/Flood_fill
-- adapted from https://github.com/Rayquaza01/minesweeper/blob/1edfc1f061032966f668cb0baf0b1f6ec6f63197/minesweeper/3.p8.lua#L112

function flood_fill(x, y, replace_color, fill_color)
	local fill_speed = make_countdown(draw_speed_fill)

	pos = {}
	pos.x = x
	pos.y = y

	local stack = {}
	add(stack, pos)

	printh("stack len: " .. #stack)
	while #stack > 0 do
		top = pop(stack)
		printh("stack value " .. top.x .. ", " .. top.y)
		if field[top.x][top.y] == replace_color then
			for d = 1, 4, 1 do
				adj = find_adjacent(top.x, top.y, d)
				if adj then
					add(stack, adj)
				end
			end
			set_field(top.x, top.y, fill_color)

			if fill_speed.is_finished() then
				fill_speed.reset()
				yield()
			end

			fill_speed.subtract(1)
		end
	end

end

-- bresenham's circle algorithm
-- based on https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/#

-- xc and yc are the midpoint
-- x and y are the distance in each direction to draw
-- will draw all 8 octants
function draw_circle_points(xc, yc, x, y, color)
	set_field(xc + x, yc + y, color)
	set_field(xc - x, yc + y, color)
	set_field(xc + x, yc - y, color)
	set_field(xc - x, yc - y, color)
	set_field(xc + y, yc + x, color)
	set_field(xc - y, yc + x, color)
	set_field(xc + y, yc - x, color)
	set_field(xc - y, yc - x, color)
end

function draw_circle(xc, yc, r, color)
	local circle_speed = make_countdown(draw_speed_circle)

	local x = 0
	local y = r
	local d = 3 - 2 * r

	draw_circle_points(xc, yc, x, y, color)
	circle_speed.subtract(1)

	while y >= x do
		x += 1

		if d > 0 then
			y -= 1
			d = d + 4 * (x - y) + 10
		else
			d = d + 4 * x + 6
		end

		draw_circle_points(xc, yc, x, y, color)
		circle_speed.subtract(1)

		if circle_speed.is_finished() then
			yield()
		end
	end
end
