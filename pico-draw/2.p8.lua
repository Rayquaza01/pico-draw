function update_menu()
    if btnp(⬇️) then
        gamestate = 0
    end

    if lmbp then
        if m_cell_y == 3 then
            if m_cell_x > 0 and m_cell_x < 6 then
                mode.selected = m_cell_x - 1
                gamestate = 0
            end
        end

        if m_cell_y == 6 then
            if m_cell_x >= 0 and m_cell_x < 8 then
                cur_color.selected = m_cell_x
                gamestate = 0
            end
        end

        if m_cell_y == 7 then
            if m_cell_x >= 0 and m_cell_x < 8 then
                cur_color.selected = m_cell_x + 8
                gamestate = 0
            end
        end

        if m_cell_x == 7 and m_cell_y == 0 then
            gamestate = 2
        end
    end
end

function draw_menu()
    map(0, 0)
	spr(1, m_x - 1, m_y - 1)
end

function update_credits()
    if btnp(⬅️) then
        gamestate = 0
    end
end

function draw_credits()
    map(9, 0)
    print("lowrezjam 2023", 1, 7, 0)
    print("♥", 1 + 4 * 14, 7, 8)

    print("pico-draw v1.0", 1, 12 + 1 * 8, 0)
    print("by rayquaza01", 1, 12 + 2 * 8, 3)

    print("⬇️ to close", 1, 12 + 5 * 8, 0)
end
