--[[------------------------------------------------------------------
  WEAPON ICONS
  Draw weapon pickups
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local WIDTH, HEIGHT = 128, 64;
  local INVALID_CHAR = "�";
  local DEFAULT_FONT = "hl2pickup_weapon";
  local DEFAULT_RB_FONT = "hl2pickup_icon_rb";

  -- Default fonts
  surface.CreateFont(DEFAULT_FONT, {
    font = "HalfLife2",
    size = 102 * HL2PICKUP:GetScale(),
    weight = 500,
    antialias = true,
    additive = true
  });

  surface.CreateFont(DEFAULT_RB_FONT, {
    font = "RealBeta's Weapon Icons",
    size = 102 * HL2PICKUP:GetScale(),
    weight = 500,
    antialias = true,
    additive = true
  });

  -- Weapon icons list
  HL2PICKUP.WeaponIcons = {};

  --[[
    Adds a font based weapon icon
    @param {number} weapon class
    @param {string} character
    @param {string} font
    @param {number|nil} x
    @param {number|nil} y
  ]]
  function HL2PICKUP:AddWeaponIcon(weaponClass, char, font, x, y)
    HL2PICKUP.WeaponIcons[weaponClass] = {char = char, font = font, x = x or 0, y = y or 0};
  end

  --[[
    Adds either a .png or a .vtf image as an icon
    @param {string} weapon class
    @param {IMaterial|number} texture
    @param {number} w
    @param {number} h
    @param {boolean|nil} coloured
  ]]
  function HL2PICKUP:AddWeaponImage(weaponClass, texture, w, h, coloured)
    HL2PICKUP.WeaponIcons[weaponClass] = {texture = texture, w = w, h = h, coloured = coloured or false};
  end

  --[[
    Adds either a .png or a .vtf image as an icon
    @param {string} weapon class
    @param {IMaterial|number} texture
    @param {number} w
    @param {number} h
    @param {number|nil} u1
    @param {number|nil} v1
    @param {number|nil} u2
    @param {number|nil} v2
    @param {number|nil} file width
    @param {number|nil} file height
    @param {boolean|nil} coloured
  ]]
  function HL2PICKUP:AddWeaponImageUV(weaponClass, texture, w, h, u1, v1, u2, v2, fileW, fileH, coloured)
    HL2PICKUP.WeaponIcons[weaponClass] = {texture = texture, w = w, h = h, u1 = u1 or 0, v1 = v1 or 0, u2 = u2 or 1, v2 = v2 or 1, fileW = fileW or w, fileH = fileH or h, coloured = coloured or false};
  end

  --[[
    Returns whether the given weapon has an icon
    @param {string} weapon class
    @return {boolean} exists
  ]]
  function HL2PICKUP:HasWeaponIcon(weaponClass)
    return HL2PICKUP.WeaponIcons[weaponClass] ~= nil;
  end

  --[[
    Gets an weapon icon's data
    @param {string} weapon class
    @return {table} icon data
  ]]
  function HL2PICKUP:GetWeaponIcon(weaponClass)
    return HL2PICKUP.WeaponIcons[weaponClass];
  end

  --[[
    Returns the height of an weapon icon
    @param {string} ammunition type
    @return {number} height
  ]]
  function HL2PICKUP:GetWeaponIconHeight(weaponClass)
    if (not HL2PICKUP:HasWeaponIcon(weaponClass)) then return WIDTH * HL2PICKUP:GetScale() * 0.83, HEIGHT * HL2PICKUP:GetScale() * 0.83; end
    local data = HL2PICKUP:GetWeaponIcon(weaponClass);
    if (data.texture ~= nil) then
      return data.h * HL2PICKUP:GetScale();
    else
      surface.SetFont(data.font);
      local w, h = surface.GetTextSize(data.char);
      return h;
    end
  end

  --[[
    Draws a weapon icon
    @param {number} x
    @param {number} y
    @param {Weapon} weapon entity
    @param {number|nil} alpha
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
  ]]
  function HL2PICKUP:DrawWeaponIcon(x, y, weapon, alpha, horAlign, verAlign)
    if (not IsValid(weapon)) then return; end
    alpha = alpha or 1;
    horAlign = horAlign or TEXT_ALIGN_RIGHT;
    verAlign = verAlign or TEXT_ALIGN_BOTTOM;
    local colour = HL2PICKUP:GetColour();
    local weaponClass = weapon:GetClass();

    -- Set missing colour if necessary
    if (not LocalPlayer():HasWeapon(weaponClass)) then
      colour = HL2PICKUP:GetCritColour();
    end

    -- Get icon size
    local w, h = WIDTH * HL2PICKUP:GetScale(), HEIGHT * HL2PICKUP:GetScale();
    if (HL2PICKUP:HasWeaponIcon(weaponClass) and HL2PICKUP:GetWeaponIcon(weaponClass).texture ~= nil) then
      w = HL2PICKUP:GetWeaponIcon(weaponClass).w * HL2PICKUP:GetScale();
      h = HL2PICKUP:GetWeaponIcon(weaponClass).h * HL2PICKUP:GetScale();
    end

    -- Setup alignment
    local tX, tY = x, y; -- Texture based icon offsets
    if (horAlign == TEXT_ALIGN_CENTER) then
      tX = x - w * 0.5;
    elseif (horAlign == TEXT_ALIGN_RIGHT) then
      tX = x - w;
    end

    if (verAlign == TEXT_ALIGN_CENTER) then
      tY = y + h * 0.5;
    elseif (verAlign == TEXT_ALIGN_BOTTOM) then
      tY = y - h;
    end

    if (HL2PICKUP:HasWeaponIcon(weaponClass)) then
      local data = HL2PICKUP:GetWeaponIcon(weaponClass);
      local colour = HL2PICKUP:GetColour();

      if (data.texture ~= nil) then
        -- Draw texture icon
        if (type(data.texture) == "number") then
          surface.SetTexture(data.texture);
        else
          surface.SetMaterial(data.texture);
        end
        surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a * alpha));

        if (data.u1 ~= nil) then
          surface.DrawTexturedRectUV(x, y, w, h, data.u1/data.fileW, data.v1/data.fileH, data.u2/data.fileW, data.v2/data.fileH);
        else
          surface.DrawTexturedRect(x, y, w, h);
        end
      else
        -- Draw font icon
        draw.SimpleText(data.char, data.font, x, y, Color(colour.r, colour.g, colour.b, colour.a * alpha), horAlign, verAlign);
      end
    else
      if (weapon:IsScripted() and weapon.DrawWeaponSelection ~= nil) then
        local bounce, info = weapon.BounceWeaponIcon, weapon.DrawWeaponInfoBox;
        weapon.BounceWeaponIcon = false;
        weapon.DrawWeaponInfoBox = false;
        weapon:DrawWeaponSelection( tX, y - (h * 1.15 * 0.5) - (HL2PICKUP:GetWeaponIconHeight(weaponClass) * 0.5), w * 1.15, h * 1.15, 255 * alpha );
        weapon.BounceWeaponIcon = bounce;
        weapon.DrawWeaponInfoBox = info;
      else
        draw.SimpleText(INVALID_CHAR, DEFAULT_FONT, x, y, Color(colour.r, colour.g, colour.b, colour.a * alpha), horAlign, verAlign);
      end
    end
  end

end
