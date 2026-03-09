# Development Roadmap

## Current Version: 0.1.0 (Prototype)
**Status**: Core systems complete, placeholder graphics

---

## Version 0.2.0 - Platform Upgrades
**Timeline**: TBD

### Planned Features
- [ ] Platform upgrade system
  - Click platform → Upgrade menu
  - Upgrade cost calculation
  - Increased production at higher levels
  - Visual changes per level

- [ ] Upgrade UI
  - Upgrade button in platform info
  - Cost preview
  - Level indicator

### Technical Debt
- [ ] Move hardcoded data to JSON config files
- [ ] Add configuration loading system

---

## Version 0.3.0 - Persistence System
**Timeline**: TBD

### Planned Features
- [ ] Save/Load functionality
  - Save platform tree to JSON
  - Save resource state
  - Save expedition progress
  - Auto-save every 5 minutes

- [ ] Load Game Menu
  - Display save slots
  - Show save info (timestamp, progress)
  - Load confirmation

- [ ] Save System UI
  - Save menu (ESC → Save)
  - Quick save (F5)
  - Quick load (F9)

### Technical Requirements
- [ ] Save file format design
- [ ] Version migration system
- [ ] Error handling for corrupted saves

---

## Version 0.4.0 - Visual Polish
**Timeline**: TBD

### Art Assets
- [ ] Replace placeholder boxes with proper 3D models
  - Platform models with details
  - Sea/ocean shader
  - Skybox
  - Environment effects

- [ ] UI Improvements
  - Custom fonts
  - Button textures
  - Panel backgrounds
  - Icons for resources

- [ ] Visual Feedback
  - Build animations
  - Combo indicators (visual lines between platforms)
  - Expedition progress bars
  - Platform selection highlight

### Audio
- [ ] Sound Effects
  - UI clicks
  - Build sounds
  - Combo activation
  - Expedition completion

- [ ] Music
  - Background music (ambient)
  - Build theme
  - Expedition theme

---

## Version 0.5.0 - Content Expansion
**Timeline**: TBD

### New Platforms
- [ ] Armory (increases combat power)
- [ ] Training Ground (expedition bonuses)
- [ ] Laboratory (faster research)
- [ ] Storage (increases resource capacity)

### New Combos
- [ ] Armory + Combat → +20% Expedition Power
- [ ] Laboratory + R&D → +30% Research Speed
- [ ] Storage + Support → +25% Resource Production
- [ ] Training Ground + Medical → -15% Expedition Time

### New Expeditions
- [ ] Rescue Mission (save captured soldiers)
- [ ] Technology Scavenging (get blueprints)
- [ ] Diplomatic Mission (gain allies)

---

## Version 0.6.0 - Advanced Systems
**Timeline**: TBD

### Staff System
- [ ] Staff recruitment
- [ ] Staff assignment to departments
- [ ] Staff leveling
- [ ] Staff skills and traits

### Department Management
- [ ] Department capacity from platforms
- [ ] Staff efficiency based on department level
- [ ] Department events

### Events
- [ ] Random events
  - Resource surplus
  - Equipment failure
  - Enemy raid
  - Discovery

---

## Version 0.7.0 - Campaign Mode
**Timeline**: TBD

### Story Elements
- [ ] Main story missions
- [ ] Character dialogue
- [ ] Cutscenes

### Mission System
- [ ] Story missions
  - Build specific platforms
  - Reach resource milestones
  - Complete expeditions

- [ ] Side missions
  - Optional objectives
  - Bonus rewards

### Progression
- [ ] Chapter system
- [ ] Unlock new platforms
- [ ] Unlock new features

---

## Version 1.0.0 - Full Release
**Timeline**: TBD

### Release Requirements
- [ ] All core features complete
- [ ] Save/Load working
- [ ] Visual polish complete
- [ ] Audio complete
- [ ] Campaign complete
- [ ] Balanced gameplay
- [ ] Performance optimized
- [ ] Bugs fixed

### Post-Launch
- [ ] DLC platforms
- [ ] New expedition types
- [ ] New game modes
  - Endless mode
  - Challenge mode
  - Creative mode

---

## Technical Debt Tracker

### High Priority
- [ ] Implement proper configuration loading
- [ ] Add error handling for edge cases
- [ ] Optimize combo detection algorithm

### Medium Priority
- [ ] Add unit tests for core systems
- [ ] Implement asset preloading
- [ ] Add performance profiling

### Low Priority
- [ ] Code documentation improvements
- [ ] Refactor for better modularity
- [ ] Add modding support

---

## Feature Ideas (Backlog)

### Gameplay
- [ ] Weather system affecting expeditions
- [ ] Day/night cycle
- [ ] Platform specialization trees
- [ ] Resource trading
- [ ] Multiplayer bases (visit friends)

### UI/UX
- [ ] Minimap
- [ ] Platform info panel
- [ ] Resource production graph
- [ ] Combo visualization tool
- [ ] Keyboard shortcuts customization

### Technical
- [ ] Settings menu (graphics, audio, controls)
- [ ] Controller support
- [ ] Cloud save sync
- [ ] Achievement system
- [ ] Steam integration

---

Last Updated: 2026-03-09
