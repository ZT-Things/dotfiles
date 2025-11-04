local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MyController = Knit.CreateController {
	Name = "MyController"
}

function MyController:KnitInit()
	print("My controller has initialized")


end

n = 0

function MyController:KnitStart()
	print("My controller has started")
	local message = Knit.GetService("Messages")

	game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui").Frame.Send.MouseButton1Up:Connect(function()
		if game.Players.LocalPlayer.PlayerGui.ScreenGui.Frame.Message.Text ~= "" then message.Sent:Fire(game.Players.LocalPlayer.PlayerGui.ScreenGui.Frame.Message.Text) end
	end)

	message.Sent:Connect(function(plr, broadcast: string)
		local dup = game:GetService("ReplicatedStorage").Template:Clone()

		dup.Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui.Frame.MainChat
		dup.LayoutOrder = n-1
		n -= 1
		dup.TextLabel.Text = plr.Name .. ": " ..  broadcast
	end)

end

return MyController
