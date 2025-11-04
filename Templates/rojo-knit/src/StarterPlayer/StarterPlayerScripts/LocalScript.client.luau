local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddControllers(game:GetService("ReplicatedStorage").Controllers)

Knit.Start():andThen(function()
	print("Client started")
end):catch(warn)
