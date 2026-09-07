# SubAbyss - Master Game Design Document (GDD)

## Overview
**SubAbyss** is a mobile-first 3D tactical submarine combat game developed in Godot 4 (GDScript).
Gameplay combines the heavy vehicular positioning and tactical pacing of *World of Tanks* with the cooperative 3-player crew dynamics and modular progression/crafting of *Warframe*.

**Target Platform:** Android Mobile (Landscape orientation, touch-driven UI, Compatibility/Mobile renderer).

---

## 1. Core Loop & Match Structure

### 1.1 Match Architecture
- **Match Format:** 3v3 Submarine Engagements (6 Submarines total, 18 players per match).
- **Crew Dynamic:** Each submarine accommodates 3 human players operating distinct, asymmetric roles in real-time.
- **Match Duration:** 10–12 minute tactical engagements across dynamic abyssal sectors.
- **Victory Conditions:**
  - **PvP Arena:** Elimination of enemy subfleet or control of abyssal control points.
  - **PvE Missions:** Completion of objective (Survival, Mobile Defense, Sabotage, Leviathan Boss) followed by successful extraction.

### 1.2 Asymmetric Crew Roles
1. **Navigator:** Helm pilot responsible for 6DoF movement, ballast depth control, gear management, and stealth maneuvering.
2. **Gunner:** Targeting and ballistics expert managing weapon slots, fixed hull abilities, lead prediction reticles, and acoustic transient control.
3. **Defense Officer:** Electronic warfare and damage control specialist operating 360° radar, Time-To-Impact (TTI) alerts, countermeasure deployment, Emergency Evasion prompts, and repair minigames.

---

## 2. Navigator Specifications

### 2.1 Hydrodynamic Flight Physics (6DoF)
- **3D Flight Simulation:** Submarines operate with underwater 6DoF dynamics (Yaw turning, Pitch angle, Ballast Heave Z axis elevation, Roll stability).
- **Drift & Hydrodynamic Inertia:** Linear momentum and water drag resistance prevent instant stopping. Turning at high speeds causes drift and cavitation noise.
- **Depth & Pressure Mechanics:** Submarines experience water density resistance, ballast buoyancy balance, and depth-based pressure limits.

### 2.2 Propulsion Gears & Noise Profiles
- **STOP (0% Thrust):** Neutral velocity, 0 dB self-generated acoustic noise. Ideal for silent ambushes.
- **SLOW (30% Thrust):** Silent cruise speed (~10 dB), minimal wake, low energy usage.
- **CRUISE (65% Thrust):** Standard combat velocity (~45 dB), balanced maneuverability and energy consumption.
- **FLANK (100% Thrust):** Maximum speed (~90 dB). Causes propeller cavitation, emitting acoustic pings that highlight the submarine on enemy sonar.
- **SILENT RUNNING:**
  - Speed locked at 20%.
  - Emits 0 dB noise across all passive sonar arrays.
  - Duration limit: 15 seconds max duration.
  - Cooldown: 30 seconds before re-engagement.

### 2.3 Tactical Maneuvers
- **Crash Dive:** Rapid ballast purge driving the sub downward at max negative pitch to break missile lock or escape surface radar.
- **Emergency Reverse:** Reverse propulsion pulse to clear tight cavern turns or avoid torpedo lines.
- **Thermocline Masking:** Hiding below warm/cold ocean thermal boundaries (Thermoclines) to refract active sonar and conceal the sub's acoustic signature.

---

## 3. Gunner Specifications

### 3.1 Customization & Slots
- **3 Custom Weapon Slots:**
  1. *Heavy Torpedo:* Slow, high-damage homing ordnance with high acoustic signature.
  2. *Supercavitating Rocket-Torpedo:* Extremely fast, unguided linear projectile designed for short-range interception.
  3. *EMP / Sub-Sea Mines:* Area-denial hazards that disable electronic systems or trigger proxy detonations.
- **2 Fixed Hull Abilities:** Chassis-specific special abilities (e.g., Heavy Hull Slam, Railgun Beam, Sonar Shockwave).

### 3.2 Dynamic Targeting & Lead Reticle
- **Lead Vector Prediction:** Calculates projectile speed, target velocity vector, distance, and water drag to display a stabilized lead prediction reticle on target hulls.
- **Target Ping Stabilization:** When the Navigator maintains active sonar ping on a target, the Gunner's lead reticle stabilizes, increasing accuracy by 40%.

### 3.3 Acoustic Transient Penalty
- **Firing Exposure:** Launching heavy torpedoes or rockets creates a loud acoustic transient spike (120+ dB).
- **Minimap Exposure:** Instantly exposes the submarine's exact location on enemy minimaps for **5 seconds** regardless of current gear or stealth state.

---

## 4. Defense Officer Specifications

### 4.1 Tactical Radar & Threat Tracking
- **360° Tactical Radar:** Sweeping active/passive display showing incoming torpedoes, mines, enemy signatures, and environmental hazards.
- **Time-To-Impact (TTI) Counter:** Real-time countdown calculation on locked incoming projectiles, alerting the crew when an impact is imminent (e.g., "TTI: 2.8s").

### 4.2 Countermeasure Systems
- **Noisemaker Decoys:** Deploys acoustic noisemakers that draw lock-on homing torpedoes away from the hull.
- **Microbubble Screens:** Releases dense thermal bubble clouds that blind enemy optical tracking and disrupt active sonar.
- **Close-In Hard-Kill:** Short-range interceptor explosive that destroys incoming projectiles within 50 meters.

### 4.3 Emergency Evasion Synergy
- **Reaction Window:** When an incoming torpedo is within critical distance, the Defense Officer can trigger an *Evasion Order*.
- **Synergy Window:** Activates a 2–3 second reaction window for the Navigator to perform an emergency dodge maneuver.
- **Damage Mitigation:** Successfully executed evasions mitigate **80% of incoming damage**.

### 4.4 Damage Control Repair Minigames
- **Hull Breach:** Tap sequence minigame to seal hull cracks and stop water flooding before hull structural integrity collapses.
- **Engine Calibration:** Slider alignment minigame to clear propeller debris and restore full gear thrust capability.
- **Circuit Breaker:** Node puzzle minigame to bypass blown fuses and restore power to weapon systems and active radar.

---

## 5. Dynamic Ocean Arenas ("Levolution")

### 5.1 Destructible Environments
- **Destructible Coral Reefs:** Firing heavy weapons or colliding with fragile coral structures shatters cover, opening lines of fire.
- **Narrow Caverns & Abyssal Trenches:** Tight spatial choke points requiring precise navigation, offering natural cover against long-range torpedoes.

### 5.2 Environmental Hazards & Events
- **Hydrothermal & Volcanic Eruptions:** Erupting vents launch thermal plumes that deal heat damage and scramble sonar targeting.
- **Thermal Blindness:** Warm water currents blind active thermal optics and mask sub signatures.
- **Abyssal Currents:** Strong underwater forces that drag submarines off trajectory unless countered by propulsion.

### 5.3 Abyssal Creep Encounters
- **Abyssal Giant Squid:** Neutral fauna boss that attacks passing subs. Defeating or pacifying the squid grants the **Abyssal Ink** buff (100% stealth & sonar invisibility for 20s).
- **EMP Eels:** Hostile bio-electric creatures that attach to sub hulls, draining energy and disabling active radar until cleared.

### 5.4 Tactical Crates
- **Match Spawns:** Maximum 3 supply crates drop randomly in the arena per match.
- **Crate Types:**
  - *Health Repair:* Restores 50% hull integrity.
  - *Cooldown Reset:* Instantly clears all weapon and ability cooldowns.
  - *Ultimate Charge:* Fills 100% of the chassis hull ability gauge.

---

## 6. Warframe-Style PvE & Crafting

### 6.1 Ocean Sector Star Chart
- **Navigation Map:** Node-based star chart across deep-sea trench sectors (Mariana Trench, Arctic Basin, Hydrothermal Abyss).
- **Mission Types:**
  - *Survival:* Endure waves of hostile automated drone subs.
  - *Mobile Defense:* Escort and protect abyssal research probes while downloading underwater data.
  - *Sabotage:* Infiltrate enemy underwater oil rigs and detonate power cores.
  - *Leviathan Boss Fights:* Multi-stage raid battles against gigantesque bio-mechanical abyss monsters.

### 6.2 Shipyard & Foundry Component Crafting
- **Subframe Crafting:** Crafting new submarine hulls requires collecting blueprint recipes and 4 core components:
  1. *Hull Sub-Assembly:* Structural plating and depth pressure tolerance.
  2. *Engine Thruster:* Cavitation suppression and thrust output.
  3. *Avionics Module:* Sonar range, lead reticle accuracy, and radar sweep speed.
  4. *Power Core:* Energy capacity, recharge rates, and ability potency.

### 6.3 Microchip (Mod) System
- **Mod Capacity & Polarities:** Subframes and weapons feature capacity limits and polarity slots (Vazarin, Naramon, Madurai) that halve mod drain when matched.
- **Elemental Combos:**
  - *Thermal:* Heat damage causing engine overheat.
  - *Cryo:* Slows target speed and maneuverability.
  - *Corrosive (Thermal + EMP):* Strips target hull armor.
  - *EMP:* Drains power grid and scrambles radar.

### 6.4 Abyssal Relic Cracking
- **Relics:** Earned from PvE missions (Axi, Neo, Meso, Lith equivalent abyssal relics).
- **Relic Cracking:** Equipped during abyssal deep dives. Collecting Abyssal Traces opens the relic upon extraction.
- **Team Reward Selection:** Upon extraction, all team members can choose 1 reward from any squad member's cracked relic pool.
