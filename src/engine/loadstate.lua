local Loading = {}

function Loading:init()
    self.logo = love.graphics.newImage("assets/sprites/kristal/kino_productions.png")
    self.logo_heart = love.graphics.newImage("assets/sprites/kristal/title_logo_heart.png")
    self.video = love.graphics.newVideo( "assets/videos/kino_rps_intro.ogv", {audio = true})
    -- could set up video audio separately so it can be stopped
    self.video:play()
    self.timer_intro = 0
    self.video_alpha = 1
end

---@enum Loading.States
Loading.States = {
    WAITING = 0,
    LOADING = 1,
    DONE = 2,
}

function Loading:enter(from, dir)
    Mod = nil
    MOD_PATH = nil

    self.loading_state = Loading.States.WAITING

    self.animation_done = false

    self.w = self.logo:getWidth()
    self.h = self.logo:getHeight()

    if not Kristal.Config["skipIntro"] then
        self.noise = love.audio.newSource("assets/sounds/kristal_intro.ogg", "static")
        self.end_noise = love.audio.newSource("assets/sounds/kristal_intro_end.ogg", "static")
        self.noise:play()
    else
        self:beginLoad()
    end

    self.key_check = not Kristal.Args["wait"]

    self.done_loading = false
end

function Loading:beginLoad()
    Kristal.clearAssets(true)

    self.loading_state = Loading.States.LOADING

    Kristal.loadAssets("", "all", "")
    Kristal.loadAssets("", "mods", "", function()
        self.loading_state = Loading.States.DONE

        Assets.saveData()

        Kristal.setDesiredWindowTitleAndIcon()

        -- Create the debug console
        Kristal.Console = Kristal.Stage:addChild(Console())
        -- Create the debug system
        Kristal.DebugSystem = Kristal.Stage:addChild(DebugSystem())

        REGISTRY_LOADED = true
    end)
end

function Loading:update()

    self.timer_intro = self.timer_intro + DT
    if self.timer_intro > 18.5 and self.timer_intro < 20 then
        self.video_alpha = 19.5-self.timer_intro
    elseif self.timer_intro >= 20 and not self.animation_done then
        self:beginLoad()
        self.animation_done = true
    end

    if self.done_loading then
        return
    end

    if (self.loading_state == Loading.States.DONE) and (self.key_check or self.animation_done or Kristal.Config["skipIntro"]) then
        -- We're done loading! This should only happen once.
        self.done_loading = true

        if Kristal.Args["test"] then
            Kristal.setState("Testing")
        elseif AUTO_MOD_START and TARGET_MOD then
            if not Kristal.loadMod(TARGET_MOD) then
                error("Failed to load mod: " .. TARGET_MOD)
            end
        else
            Kristal.setState("MainMenu")
        end
    end
end


function Loading:draw()
    if self.video ~= nil then
        Draw.setColor(1, 1, 1, self.video_alpha)
        love.graphics.draw(self.video,0,0)
    end
end

function Loading:onKeyPressed(key)
    self.key_check = true
    if self.loading_state == Loading.States.WAITING then
        self:beginLoad()
    end
end

return Loading
