local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServices(game:GetService("ServerStorage").Services)

Knit.Start():andThen(function()
	print("Server started")
end):catch(warn)
