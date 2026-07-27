# Disclaimer

**ERS (Emergency Response Simulator)** is a **fictive roleplay simulator**. All events, callouts, scenarios, and content in this project are **fictional** and **not based on real-life events**. They are created purely for entertainment and roleplay purposes within a game environment.

Any resemblance to actual incidents, persons, or situations is coincidental and unintentional.

---

## Data Collection (ERS Statistics)

When the optional **ERS Statistics / Leaderboard** feature is enabled (`Config.Leaderboard.TrackStatistics = true` in `config/leaderboard-config.lua`), the resource collects, transmits and stores limited gameplay data on infrastructure operated by **Nights Software**.

### What is collected
- FiveM/Cfx.re user ID (`player_cfx_id`) and current FiveM display name (`player_name`).
- Server Cfx.re ID (`server_cfx_id`).
- Gameplay counters: shift time, CPRs performed, arrests, persons delivered to hospital, vehicles impounded and callouts completed.
- Technical timestamps (`created_at`, `updated_at`).

No IP addresses, hardware IDs, chat content, voice, location coordinates or payment information are collected by this resource.

### Where it is sent and stored
Data is transmitted over HTTPS to `api.nights-software.com` and may be displayed publicly on the global leaderboard at `stats.nights-software.com`. Storage and processing take place on infrastructure controlled by Nights Software and may involve international transfers, including outside the EU/EEA and the UK.

### Purpose and legal basis
The data is processed for the purpose of providing a cross-server statistics and leaderboard service. The legal basis is the legitimate interest of Nights Software and the server operator in providing this functionality (Art. 6(1)(f) GDPR), and/or the player's consent to participate by joining a server where the feature is enabled.

### Responsibilities
- **Nights Software** acts as the operator of the leaderboard backend and stores the data described above.
- **Server owners** using this resource are responsible for informing their players that this feature is enabled and for honouring data subject requests directed at them. Server owners can disable all tracking at any time by setting `Config.Leaderboard.TrackStatistics = false` and restarting the resource; no data is then transmitted.

### Player rights
Players worldwide may have rights under applicable law (GDPR / UK GDPR / CCPA / CPRA / LGPD / PIPEDA and others), including access, rectification, erasure, restriction, objection and data portability. Requests can be sent to Nights Software via the contact channels listed on the official Nights Software Webstore: https://store.nights-software.com or via our support sections in Discord: https://discord.nights-software.com.
