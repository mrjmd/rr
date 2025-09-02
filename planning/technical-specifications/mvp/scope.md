# MVP Scope: Rando's Reservoir Prototype

## 🎯 MVP Goal
Create a **playable 10-minute experience** that proves the core emotional mechanic works and is engaging.

## Core Concept (The ONE Thing)
**"Managing a crying baby while trying to complete tasks creates authentic emotional pressure"**

That's it. Everything else is extra.

## What's IN Scope for MVP

### Single Scene: "Making Coffee With Baby"
A single room where you need to make coffee while managing a fussy baby.

### Two Meters Only
1. **Fuss Meter** (Baby's state)
   - Fills over time when baby is put down
   - Resets when picked up
   - Audio/visual feedback as it rises

2. **Frustration Meter** (Your state)  
   - Fills when tasks are interrupted
   - Fills when baby cries too long
   - One simple choice: Breathe (reduce) or Snap (consequence)

### Core Mechanics
- **Pick Up/Put Down Baby** (Space bar)
- **One-Handed vs Two-Handed Tasks**
  - One-handed: Move around, open cabinets
  - Two-handed: Pour water, grind coffee
- **Single Task Goal**: Make one cup of coffee

### Minimum Viable Art
- Single room (kitchen)
- Basic sprites (don't need animation)
- Two meter bars
- Simple baby sprite (held/in crib)

### Success Conditions
- Player makes coffee = Win screen
- Frustration maxes out = Fail screen
- That's it

## What's OUT of Scope for MVP

### ❌ NOT Building (Yet)
- Multiple rooms or scenes
- Day/night cycles  
- Other family members
- Dialogue system
- Save/load functionality
- Main menu (just start in kitchen)
- Settings menu
- Multiple days
- Branching narratives
- Dream sequences
- Overwhelm meter
- Reservoir meter
- Connection meter
- Clarity meter
- Complex emotional state tracking
- Pattern recognition
- Conditional content
- Audio/music (just basic SFX)
- Animations beyond basic movement
- Mobile support
- Controller support
- Achievements
- Tutorial beyond basic control prompts

## Development Phases

### Week 1: Core Loop
- [ ] Baby pick up/put down working
- [ ] Fuss meter filling/resetting
- [ ] Movement with/without baby
- [ ] ONE two-handed interaction (pick up kettle)

**Deliverable**: Can pick up baby, walk around, put baby down, watch meter fill

### Week 2: Task System  
- [ ] Coffee making steps (5-6 simple steps)
- [ ] Frustration meter when interrupted
- [ ] Basic win/lose conditions
- [ ] Simple UI for both meters

**Deliverable**: Can complete coffee task while managing baby

### Week 3: Polish & Feedback
- [ ] Balancing timers (how fast should fuss build?)
- [ ] Visual/audio feedback for meter states
- [ ] Playtesting with 5 people
- [ ] Iterate based on feedback

**Deliverable**: Playable prototype that feels good

## Technical Simplifications

### Instead of Complex Systems, Use:
- **Timer**: Simple float that counts up (fuss meter)
- **Boolean**: holding_baby = true/false
- **Enum**: Task states (not started, in progress, complete)
- **Basic State Machine**: Menu → Playing → Win/Lose

### File Structure (Minimal)
```
src/
  scenes/
    kitchen.tscn
    game_over.tscn
  scripts/
    player_controller.gd
    baby_manager.gd
    task_coffee.gd
    meter_display.gd
```

That's it. Maybe 500 lines of code total.

## Success Metrics for MVP

### Must Have
- [ ] Players understand controls in <30 seconds
- [ ] Core loop is clear within 1 minute  
- [ ] Emotional response (frustration) is genuine
- [ ] Players want to try again after failing

### Nice to Have
- [ ] Players laugh or relate to the experience
- [ ] Takes 5-10 attempts to "master"
- [ ] Players suggest features (means they're engaged)

## Common Pitfalls to Avoid

### Don't Add:
- "Just one more meter"
- "A quick dialogue system"
- "Different difficulty modes"
- "Multiple baby states"
- "Character customization"
- "Score tracking"
- "Online leaderboards"

Every single addition multiplies complexity.

## The Hard Questions

1. **Will this prototype be FUN without any story?** (It should be)
2. **Can my mom understand how to play?** (It should be that simple)
3. **Could I build this in GameMaker/Scratch?** (You should be able to)
4. **Would I play this more than once?** (Be honest)

## After MVP: What's Next?

ONLY after the MVP is fun and polished:

### Version 0.2
- Add ONE more task (eat dinner?)
- Add simple dialogue bubbles
- Add Rage meter with suppress/leak choice

### Version 0.3  
- Add second room
- Add one family member
- Add save/load

### Version 0.4
- Now maybe think about Day structure

## Reality Check Calculations

### Current Full Game Scope
- 8 days × 5 scenes = **40 scenes minimum**
- 5 meters × 3 states each = **15 emotional states**
- Branching paths = **100+ possible combinations**
- Estimated time: **2+ years solo**

### MVP Scope
- 1 scene
- 2 meters × 2 states = **4 states total**
- No branching
- Estimated time: **3-4 weeks**

**Which would you rather have?**
- A finished prototype in a month that you can show people
- An unfinished ambitious game in 2 years that might never ship

## The Most Important Rule

**If you're thinking "but the game needs...", stop.**

The game needs to EXIST first. Everything else is optional.

Build the MVP. Make it fun. Everything else can come later.

## Your Next Action

1. Close all planning documents except this one
2. Open Godot
3. Create kitchen.tscn
4. Add a player sprite
5. Make it move with arrow keys
6. Add a baby sprite
7. Press Space to pick up/put down

That's your day 1. Stop planning. Start building.