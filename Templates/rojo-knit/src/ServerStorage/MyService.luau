local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Test = Knit.CreateService {
	Name = "TestService",
	Client = {},
}

function Test.Client:AddOne(player: Player,n: number):number
	return self.Server:Add(1,n)
end

function Test:Add(n1: number, n2: number):number
	return n1 + n2
end

return Test
