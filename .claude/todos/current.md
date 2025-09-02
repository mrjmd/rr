# Rando's Reservoir - Current Session TODOs
*Last Updated: 2025-09-02 23:45*
*Session Started: 2025-09-02 23:45*
*Project Phase: Game Features - Scene Implementation*

## 🚀 Current Sprint Goal
Implement Day 1 Scene 4 "Evening and Dream" - The core emotional mechanics with meter systems, baby interactions, and conditional gameplay based on player choices.

## 🔄 IN PROGRESS (Max 1 item)
*Ready to start first task*

## ✅ COMPLETED THIS SESSION
*New session - ready for game features*

## 📋 PENDING (Priority Order)
1. [ ] Design and implement meter system architecture (Rage, Overwhelm, Reservoir)
   - Why: Core emotional tracking system needed for all gameplay
   - Files: Create meter system singleton and UI components
   - Depends on: Nothing - foundational system
   
2. [ ] Create baby interaction system with Hold Baby status and Fuss Meter  
   - Why: Central mechanic for Part 2 unpacking sequence
   - Files: Baby controller, status system, timer mechanics
   - Depends on: Meter system for Fuss Meter
   
3. [ ] Implement Day 1 Scene 4 Part 2: One-Handed Burden unpacking mechanics
   - Why: First major gameplay sequence to implement
   - Files: Unpacking scene, interaction system, inventory management
   - Depends on: Baby interaction system
   
4. [ ] Build conditional sanctuary bedtime minigame with rhythm mechanics
   - Why: Major "Island of Peace" mechanic with conditional outcomes
   - Files: Rhythm game controller, audio system integration
   - Depends on: Meter system to check for "Rage Leak" conditions
   
5. [ ] Create dream framework with meter-based visual/audio modifiers
   - Why: Ending sequence that reflects player's emotional state
   - Files: Dream scene, visual effects, audio modulation
   - Depends on: Meter system for dream state modification

## 🔍 RECOVERY CONTEXT
### Currently Working On
- **Task**: Ready to start meter system architecture
- **File**: Will create new meter system files
- **Problem**: Need foundational emotional tracking for all game mechanics
- **Solution**: Create singleton-based meter system with UI integration

### Key Decisions This Session
- Ready to make first decisions for game feature implementation

### Files to Create/Modify
- `globals/meter_system.gd` - Core emotional meter tracking
- `src/scripts/ui/meters/` - UI components for meter display
- `src/scenes/gameplay/day1_scene4/` - Scene implementation
- `src/scripts/gameplay/baby_interaction.gd` - Baby holding mechanics

### Commands to Resume
```bash
# Continue with Godot editor:
cd /Users/matt/Projects/randos-reservoir
godot project.godot

# Test any gameplay features with F9:
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/matt/Projects/randos-reservoir --maximized
# Then press F9 for automated testing when features are ready
```

## 🎯 Definition of Done for Current Phase
- [ ] All three meters (Rage, Overwhelm, Reservoir) working with UI display
- [ ] Baby interaction system allows one-handed vs two-handed actions
- [ ] Fuss Meter timer system works correctly
- [ ] Unpacking sequence playable with proper challenge balance
- [ ] Bedtime minigame has two difficulty modes based on prior player choices
- [ ] Dream sequence reflects meter states with appropriate audio/visual changes
- [ ] All systems tested with screenshots and manual verification

## 📝 Session Notes
- 23:45: Archived completed menu infrastructure work
- 23:45: Set up new session focused on actual game features
- Reference: Day 1 Scene 4 planning in `/planning/scenes/day-1/04_evening_and_dream.md`

## ⚠️ Blockers & Issues
*None currently - all infrastructure complete and ready for feature development*

## 🔜 Next Session Priority
After completing meter system architecture:
1. Focus on baby interaction mechanics as the core challenge
2. Build unpacking sequence as first major gameplay
3. Implement conditional bedtime experience

## 📚 REFERENCE MATERIALS

### Scene 4 Overview (from planning doc):
1. **Part 1: The Ghosting** - Brother leaves, judgment vs empathy choice
2. **Part 2: One-Handed Burden** - Unpacking with clingy baby mechanics  
3. **Part 3: Salad of Solitude** - Narrative eating scene
4. **Part 4: Conditional Sanctuary** - Bedtime minigame (peaceful vs stressful)
5. **Part 5: Dream Framework** - Meter-influenced dream with morning reflection

### Key Mechanics to Implement:
- **Hold Baby Status**: Limits interactions to one-handed actions
- **Fuss Meter**: Timer for how long baby can be put down
- **Two-Handed Actions**: Require putting baby down temporarily
- **Conditional Outcomes**: Bedtime difficulty based on earlier "Rage Leak"
- **Dream Modifiers**: Visual/audio changes based on final meter values

### Meter System Requirements:
- **Rage Meter**: Tracks anger buildup, triggers "Rage Leak" events
- **Overwhelm Meter**: Cognitive load from environment/tasks
- **Reservoir Meter**: Accumulated emotional weight/suppression
- **UI Display**: Visual representation of all three meters
- **Save/Load**: Meter states persist between scenes
- **Events**: Meter changes trigger gameplay consequences

## 🏗️ ARCHITECTURE NOTES
- Use Godot's singleton pattern for meter system (autoload)
- Component-based baby interaction (can be attached to different objects)
- Scene-based approach for each part of Day 1 Scene 4
- Signal-driven communication between systems
- Resource files (.tres) for meter configurations and thresholds

## 🧪 TESTING APPROACH
- F9 MenuVerifier system is working for menu testing
- Will need new testing tools for gameplay mechanics
- Screenshot verification for meter UI states
- Manual testing with specific meter value scenarios
- Automated testing for baby interaction timers

**INFRASTRUCTURE COMPLETE - READY TO BUILD REAL GAME!**