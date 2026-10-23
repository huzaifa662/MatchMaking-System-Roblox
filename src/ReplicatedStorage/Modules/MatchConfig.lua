--!strict

export type ModeConfig = {
	MinPlayers: number,
	MaxPlayers: number,
	TeamSize: number,
	WinCondition: "Kills" | "Time",
	WinKills: number?,
	MatchDuration: number,
}

local MatchConfig = {
	USE_RESERVED_SERVERS = false,
	DEMO_MODE = false, -- set true for single-player demo
	MatchPlaceId = 0,

	Modes = {
		["1v1"] = {
			MinPlayers = 2,
			MaxPlayers = 2,
			TeamSize = 1,
			WinCondition = "Kills",
			WinKills = 5,
			MatchDuration = 120,
		} :: ModeConfig,
	},

	QueueTimeout = 120,
	CountdownDuration = 5,
	ResultsDuration = 10,
}

return MatchConfig
