local ui_get, ui_set, ui_add_checkbox, ui_add_dropdown, ui_add_multi_dropdown, ui_add_label, ui_add_cog, cvar_find_var, callbacks_register, render_create_font, anti_aim_inverted, ui_add_slider, client_is_alive = ui.get, ui.set, ui.add_checkbox, ui.add_dropdown, ui.add_multi_dropdown, ui.add_label, ui.add_cog, cvar.find_var, callbacks.register, render.create_font, anti_aim.inverted, ui.add_slider, client.is_alive

local menu = {
    switch = ui_add_checkbox( 'Enable arrows' ),
    dropdown = ui_add_dropdown( ' ', { 'Manual anti-aim', 'Inverter side' } ),
    color_label = ui_add_label( 'Active arrow accent' ) ,
    color_active_color = ui_add_cog( 'Color', true, false ),
    slider = ui_add_slider( 'Arrows offset', 20, 100 ),
}

menu.handle = function()
    local switch = menu.switch:get()
    menu.dropdown:set_visible( switch )
    menu.color_label:set_visible( switch )
    menu.color_active_color:set_visible( switch )
    menu.slider:set_visible( switch )
end

local arrows = {}

arrows.ref = {
    left = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual left key' ),
    back = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual backwards key' ),
    right = ui_get( 'Rage', 'Anti-aim', 'General', 'Manual right key' ),
    screen_size = { render.get_screen() }
}

arrows.var = {
    pos = { x = arrows.ref.screen_size[1] / 2, y = arrows.ref.screen_size[2] / 2 },
    font = render_create_font( 'verdana', 27, 300, bit.bor(font_flags.antialias) )
}

arrows.handle_manual = function()
    local text_size = { arrows.var.font:get_size('⮜') }
    local colors = {
        active = menu.color_active_color:get_color(),
        inactive = color.new(150, 150, 150, 150)
    }
    local offset = menu.slider:get()
    arrows.var.font:text( arrows.var.pos.x - offset - text_size[1], arrows.var.pos.y - text_size[2] / 2 - 2, arrows.ref.left:get_key() and colors.active or colors.inactive, '⮜' )
    arrows.var.font:text( arrows.var.pos.x - text_size[1] / 2 - 1, arrows.var.pos.y + offset - 10, arrows.ref.back:get_key() and colors.active or colors.inactive, '⮟' )
    arrows.var.font:text( arrows.var.pos.x + offset, arrows.var.pos.y  - text_size[2] / 2 - 2, arrows.ref.right:get_key() and colors.active or colors.inactive, '⮞' )
end

arrows.handle_inverter = function()
    local text_size = { arrows.var.font:get_size('❰') }
    local colors = {
        active = menu.color_active_color:get_color(),
        inactive = color.new(255, 255, 255, 255)
    }
    local offset = menu.slider:get()
    arrows.var.font:text( arrows.var.pos.x - offset - text_size[1], arrows.var.pos.y - text_size[2] / 2 - 2, not anti_aim_inverted() and colors.active or colors.inactive, '❰' )
    arrows.var.font:text( arrows.var.pos.x + offset, arrows.var.pos.y  - text_size[2] / 2 - 2, anti_aim_inverted() and colors.active or colors.inactive, '❱' )
end

local all_callbacks = {}

all_callbacks.on_paint = function()
    menu.handle()

    local switch = menu.switch:get()
    if not switch then
        return
    end

    if not client_is_alive() then
        return
    end

    if menu.dropdown:get() == 0 then
        arrows.handle_manual()
    end

    if menu.dropdown:get() == 1 then
        arrows.handle_inverter()
    end
end

callbacks_register( 'paint', all_callbacks.on_paint )