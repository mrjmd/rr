# MVP Implementation Plan: 3-Week Sprint

## Week 1: Core Mechanics (Dec 2-8)

### Day 1-2: Basic Setup
- [ ] Create kitchen.tscn with floor/walls
- [ ] Add player sprite that moves with arrow keys
- [ ] Add baby sprite in crib (static)
- [ ] Add coffee maker sprite (static)

**Success Criteria**: Can walk around empty kitchen

### Day 3-4: Baby Pickup System
- [ ] Implement pick up/put down with spacebar
- [ ] Change player sprite when holding baby
- [ ] Baby sprite disappears from crib when held
- [ ] Add debug text showing holding state

**Success Criteria**: Can pick up and put down baby repeatedly

### Day 5-7: Fuss Meter
- [ ] Add fuss meter UI bar
- [ ] Implement timer that fills meter when baby is down
- [ ] Reset meter when baby picked up
- [ ] Add crying sound at 100% (even just a beep)

**Success Criteria**: Meter fills, baby "cries", picking up stops crying

## Week 2: Task System (Dec 9-15)

### Day 8-9: Coffee Task Steps
- [ ] Add 5 interaction points (sink, cabinet, etc.)
- [ ] Create simple state machine for coffee progress
- [ ] Show checklist of coffee steps in UI
- [ ] Block interactions when holding baby

**Success Criteria**: Can complete coffee by visiting stations in order

### Day 10-11: Frustration Meter
- [ ] Add frustration meter UI bar
- [ ] Increase when baby cries
- [ ] Increase when tasks interrupted
- [ ] Add game over at 100%

**Success Criteria**: Can lose the game by ignoring baby

### Day 12-14: Win/Lose States
- [ ] Add win screen when coffee complete
- [ ] Add lose screen when frustrated
- [ ] Add restart button
- [ ] Add timer to show completion time

**Success Criteria**: Complete game loop works

## Week 3: Polish & Balance (Dec 16-22)

### Day 15-16: Tuning
- [ ] Playtest and adjust fuss meter speed
- [ ] Playtest and adjust frustration rate
- [ ] Playtest and adjust task durations
- [ ] Find the "sweet spot" of difficulty

**Success Criteria**: Takes 2-3 attempts to win

### Day 17-18: Feedback Polish
- [ ] Add progress bars for tasks
- [ ] Add "Can't do this while holding baby" message
- [ ] Add visual feedback for meter states (color changes)
- [ ] Add particle effect when completing task

**Success Criteria**: Players understand what's happening without explanation

### Day 19-21: Final Testing
- [ ] Test with 5 different people
- [ ] Document common failure points
- [ ] Final balance adjustments
- [ ] Create 1-page how-to-play guide

**Success Criteria**: New players understand in <1 minute

## Daily Development Routine

### Morning (1 hour)
1. Read yesterday's progress
2. Pick ONE task from the list
3. Implement the simplest version
4. Test it works

### Afternoon (1 hour)
1. Fix any bugs from morning
2. Add ONE small improvement
3. Test again
4. Commit working code

### Evening (30 min)
1. Update todo list
2. Note what worked/didn't work
3. Plan tomorrow's ONE task

## What You're NOT Doing

During these 3 weeks, you are NOT:
- Adding "just one more feature"
- Creating a main menu
- Adding story elements
- Implementing save/load
- Creating multiple rooms
- Adding other characters
- Working on art style
- Composing music
- Adding achievements
- Building a settings menu
- Creating difficulty modes
- Adding accessibility features (yet)

## Definition of "Done" for MVP

The MVP is DONE when:
1. ✅ Player can complete coffee task
2. ✅ Baby cries and needs attention
3. ✅ Meters create pressure
4. ✅ Win/lose states work
5. ✅ Game restarts properly
6. ✅ New player understands in 1 minute
7. ✅ Core loop is actually fun

NOT when:
- ❌ It looks pretty
- ❌ It has a story
- ❌ It has perfect balance
- ❌ It has no bugs
- ❌ It matches the full vision

## Risk Mitigation

### If you fall behind:
- Cut coffee steps from 5 to 3
- Remove frustration meter (just use timer)
- Skip all polish, focus on function

### If you finish early:
- DO NOT add features
- Polish what exists
- Get more playtesters
- Start planning v0.2 (but don't build it)

## Success Metrics

### Quantitative
- Build completes in <5 seconds
- Runs at 60 FPS constantly
- Uses <100MB RAM
- Code is <500 lines total

### Qualitative
- Players laugh or say "oh no!" when baby cries
- Players immediately try again after failing
- Players develop strategies
- Players can explain the game to others

## The Three Laws of MVP Development

1. **If it's not broken, don't add to it**
2. **If players don't notice it's missing, it's not needed**
3. **If you can't test it in 30 seconds, it's too complex**

## Daily Mantras

- "What's the simplest thing that could work?"
- "Is this making the core loop better?"
- "Would this feature matter if I only had one day left?"
- "Can I ship without this?"
- "Is this feature or polish?"

## After MVP Ships

ONLY after you have a working, fun prototype:

### Version 0.2 Planning (NOT BUILDING)
- Analyze what players enjoyed most
- Identify biggest pain points
- Plan ONE new feature
- Keep scope equally small

### Learning Review
- What took longer than expected?
- What was easier than expected?
- What would you cut if starting over?
- What was actually essential?

## Emergency Escape Hatch

If after Week 1 the core mechanic isn't fun:
- STOP
- Pivot to even simpler game
- Consider: Just a crying baby simulator (no tasks)
- Or: Just a coffee-making game (no baby)
- Find the fun in ONE mechanic first

## Remember

Every famous indie game started with a prototype that was:
- Ugly
- Simple  
- Focused
- Fun

Your MVP should be all four.

Ship something small and fun rather than nothing large and ambitious.