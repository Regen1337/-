
-- Here is where all of your clientside hooks should go.

-- Disables the crosshair permanently.
function Schema:CharacterLoaded(character)
	self:ExampleFunction("@serverWelcome", character:GetName())
end

function Schema:LoadFonts(font, genericFont)
	print("loaded fonts")
	surface.CreateFont("R3D2DFont", {
		font = font,
		size = 128,
		extended = true,
		weight = 100
	})

	surface.CreateFont("R3D2DMediumFont", {
		font = font,
		size = 48,
		extended = true,
		weight = 100
	})

	surface.CreateFont("R3D2DSmallFont", {
		font = font,
		size = 24,
		extended = true,
		weight = 400
	})

	surface.CreateFont("RTitleFont", {
		font = font,
		size = ScreenScale(30),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RSubTitleFont", {
		font = font,
		size = ScreenScale(16),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RMenuMiniFont", {
		font = font,
		size = math.max(ScreenScale(4), 18),
		weight = 300,
	})

	surface.CreateFont("RMenuButtonFont", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 100
	})

	surface.CreateFont("", {
		font = font,
		size = ScreenScale(10),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RMenuButtonFontThick", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 300
	})

	surface.CreateFont("RMenuButtonLabelFont", {
		font = font,
		size = 28,
		extended = true,
		weight = 100
	})

	surface.CreateFont("RMenuButtonHugeFont", {
		font = font,
		size = ScreenScale(24),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RToolTipText", {
		font = font,
		size = 20,
		extended = true,
		weight = 500
	})

	surface.CreateFont("RMonoSmallFont", {
		font = font,
		size = 12,
		extended = true,
		weight = 800
	})

	surface.CreateFont("RMonoMediumFont", {
		font = font,
		size = 22,
		extended = true,
		weight = 800
	})

	-- The more readable font.
	font = genericFont

	surface.CreateFont("RBigFont", {
		font = font,
		size = 36,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("RMediumFont", {
		font = font,
		size = 25,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("RNoticeFont", {
		font = font,
		size = math.max(ScreenScale(8), 18),
		weight = 100,
		extended = true,
		antialias = true
	})

	surface.CreateFont("RMediumLightFont", {
		font = font,
		size = 25,
		extended = true,
		weight = 200
	})

	surface.CreateFont("RMediumLightBlurFont", {
		font = font,
		size = 25,
		extended = true,
		weight = 200,
		blursize = 4
	})

	surface.CreateFont("RGenericFont", {
		font = font,
		size = 20,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("RChatFont", {
		font = font,
		size = math.max(ScreenScale(7), 17) * ix.option.Get("chatFontScale", 1),
		extended = true,
		weight = 600,
		antialias = true
	})

	surface.CreateFont("RChatFontItalics", {
		font = font,
		size = math.max(ScreenScale(7), 17) * ix.option.Get("chatFontScale", 1),
		extended = true,
		weight = 600,
		antialias = true,
		italic = true
	})

	surface.CreateFont("RSmallTitleFont", {
		font = font,
		size = math.max(ScreenScale(12), 24),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RMinimalTitleFont", {
		font = font,
		size = math.max(ScreenScale(8), 22),
		extended = true,
		weight = 800
	})

	surface.CreateFont("RSmallFont", {
		font = font,
		size = math.max(ScreenScale(6), 17),
		extended = true,
		weight = 500
	})

	surface.CreateFont("RItemDescFont", {
		font = font,
		size = math.max(ScreenScale(6), 17),
		extended = true,
		shadow = true,
		weight = 500
	})

	surface.CreateFont("RSmallBoldFont", {
		font = font,
		size = math.max(ScreenScale(8), 20),
		extended = true,
		weight = 800
	})

	surface.CreateFont("RItemBoldFont", {
		font = font,
		shadow = true,
		size = math.max(ScreenScale(8), 20),
		extended = true,
		weight = 800
	})

	-- Introduction fancy font.
	font = "Roboto Th"

	surface.CreateFont("RIntroTitleFont", {
		font = font,
		size = math.min(ScreenScale(128), 128),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RIntroTitleBlurFont", {
		font = font,
		size = math.min(ScreenScale(128), 128),
		extended = true,
		weight = 100,
		blursize = 4
	})

	surface.CreateFont("RIntroSubtitleFont", {
		font = font,
		size = ScreenScale(24),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RIntroSmallFont", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RIconsSmall", {
		font = font,
		size = 22,
		extended = true,
		weight = 500
	})

	surface.CreateFont("RSmallTitleIcons", {
		font = font,
		size = math.max(ScreenScale(11), 23),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RIconsMedium", {
		font = font,
		extended = true,
		size = 28,
		weight = 500
	})

	surface.CreateFont("RIconsMenuButton", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 100
	})

	surface.CreateFont("RIconsBig", {
		font = font,
		extended = true,
		size = 48,
		weight = 500
	})
end