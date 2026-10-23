# Matchmaking System (Roblox)

A portfolio-grade 1v1 matchmaking system for Roblox, built with Luau.

## Features
- Server-authoritative queue (join/leave)
- Balanced team formation (1v1)
- 5-second countdown on match found
- In-match kill tracking, respawn, win conditions (first to 5 kills or 120s)
- Results screen + return to lobby
- Reserved-server teleport path (production toggle)
- State machine + anti-exploit validation
- Responsive UI (bottom-center, countdown overlay)

## Structure
```
src/
  ReplicatedStorage/
    Modules/
      MatchConfig.lua
      QueueService.lua
  ServerScriptService/
    MatchmakingServer.lua
  StarterPlayer/
    StarterPlayerScripts/
      MatchmakingClient.lua
```

## Setup
1. Create a Roblox place (lobby).
2. (Optional) Create a second place for matches and set `MatchPlaceId` in `MatchConfig`.
3. Copy scripts into the corresponding services.
4. Ensure a `SpawnLocation` named `SpawnLocation` exists in Workspace for default spawn.
5. (Optional) Create `Spawn1` and `Spawn2` parts for match spawns.

## Config
Edit `MatchConfig`:
- `DEMO_MODE`: set `true` for single-player testing (auto-starts match with 1 player).
- `USE_RESERVED_SERVERS`: set `true` + `MatchPlaceId` for production teleport.
- `Modes`: adjust team sizes, win conditions, durations.

## Notes
- Requires `Remotes` folder in `ReplicatedStorage` (auto-created by server).
- DataStore not included; add your own stats persistence if needed.
- Tested in Roblox Studio.

## License
MIT
