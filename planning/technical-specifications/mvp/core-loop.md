# MVP Core Loop Specification

## The Loop in One Sentence
**"Pick up baby to stop crying, put down baby to do tasks, manage rising frustration."**

## The 30-Second Experience

1. Baby starts crying (fuss meter rising)
2. Player picks up baby (stops crying)
3. Player can't make coffee while holding baby
4. Player puts baby down to work on coffee
5. Baby starts crying again after ~10 seconds
6. Player gets frustrated (frustration meter rises)
7. Repeat until coffee is made (win) or rage maxes out (lose)

## Core Mechanics Flowchart

```
START
  ↓
Baby in crib (crying)
  ↓
[PLAYER CHOICE]
  ├─→ Pick up baby → Crying stops → Can't do two-handed tasks
  │                        ↓
  │                   Put down baby
  │                        ↓
  └─←─←─←─←─←─←─←─← Timer starts ←─┘
           ↓
    Fuss meter rises
           ↓
    [After 10 seconds]
           ↓
    Baby crying loudly
           ↓
    Frustration +10/second
           ↓
    [PLAYER MUST PICK UP BABY]
```

## Input: Two Buttons

### Space Bar: Baby Interaction
- **When not holding**: Pick up baby
- **When holding**: Put down baby
- **Visual feedback**: Baby sprite changes position
- **Audio feedback**: Crying stops/starts

### E Key: Interact with Objects
- **When not holding baby**: Two-handed actions work
- **When holding baby**: "Can't do this while holding baby" message
- **Visual feedback**: Progress bar for coffee steps
- **Audio feedback**: Success/fail sounds

## The Numbers (Tunable)

```gdscript
# These are starting points - will need playtesting
const FUSS_RATE = 1.0  # Fuss meter fills at 1% per second
const FUSS_MAX = 100.0  # Baby cries at 100%
const CALM_DURATION = 10.0  # Seconds baby stays calm when put down
const FRUSTRATION_RATE = 2.0  # When baby is crying
const FRUSTRATION_MAX = 100.0  # Game over at 100%
const COFFEE_STEPS = 5  # Number of interactions to make coffee
const STEP_DURATION = 3.0  # Seconds per coffee step
```

## States: Keep It Simple

### Player States (Enum)
1. **IDLE** - Can move and interact
2. **HOLDING_BABY** - Can move, can't do two-handed tasks
3. **INTERACTING** - Doing a task (can't move)

### Baby States (Enum)
1. **CALM** - In crib, quiet, fuss meter rising slowly
2. **FUSSING** - In crib, whimpering, fuss meter >50%
3. **CRYING** - In crib, loud crying, fuss meter = 100%
4. **HELD** - Being held, content, fuss meter = 0

### Coffee Task States (Enum)
1. **NEED_WATER** - Go to sink
2. **NEED_GROUNDS** - Go to cabinet
3. **NEED_FILTER** - Go to drawer
4. **NEED_BREW** - Go to coffee maker
5. **NEED_POUR** - Wait for brewing
6. **COMPLETE** - Coffee ready!

## Minimum Viable Feedback

### Visual
- **Fuss Meter**: Simple progress bar that fills (green→yellow→red)
- **Frustration Meter**: Simple progress bar (blue→orange→red)
- **Baby Sprite**: 2 frames (calm face, crying face)
- **Coffee Progress**: Checklist of steps with checkmarks

### Audio (Just Three Sounds)
1. **baby_cry.ogg** - Loops when fuss = 100%
2. **pickup_putdown.ogg** - Plays on baby interaction
3. **task_complete.ogg** - Plays when coffee step done

### Text (Minimal)
- "Press SPACE to pick up baby"
- "Can't do this while holding baby"
- "Coffee is ready!"
- "Too frustrated to continue..."

## Win/Lose Conditions

### Win
```gdscript
if coffee_task_state == COMPLETE:
    show_message("You made coffee! Parenting level: SURVIVOR")
    show_time_taken()
    show_retry_button()
```

### Lose
```gdscript
if frustration_meter >= 100:
    show_message("Too overwhelmed to continue...")
    show_how_far_you_got()
    show_retry_button()
```

## What Makes It Fun?

### The Tension
- You KNOW the baby will cry soon
- You're racing against the calm timer
- Each task takes just longer than comfortable

### The Humor
- Coffee is such a simple goal
- Baby cries at the worst possible moment
- Relatable parent frustration

### The Challenge
- Optimizing your route through the kitchen
- Timing when to put baby down
- Learning the rhythm of fuss/calm cycles

## Complexity Budget

**Total Scripts**: 4
1. `player_controller.gd` (~100 lines)
2. `baby_system.gd` (~80 lines)
3. `coffee_task.gd` (~60 lines)
4. `ui_meters.gd` (~40 lines)

**Total Scenes**: 3
1. `kitchen.tscn` (main game)
2. `ui_overlay.tscn` (meters and messages)
3. `game_over.tscn` (win/lose screen)

**Total Assets Needed**: Minimal
- 1 room background
- 1 player sprite (2 frames: normal, holding)
- 1 baby sprite (2 frames: calm, crying)
- 5 interactive object sprites (sink, cabinet, etc.)
- 2 meter bar textures
- 3 sound effects

## Balancing Guidelines

### Too Easy If:
- Players succeed on first try
- Never reach >50% frustration
- Can ignore baby for long periods

### Too Hard If:
- Players can't finish coffee in 10 attempts
- Frustration maxes before step 3
- Feels impossible/unfair

### Just Right When:
- Takes 2-3 attempts to succeed
- Players develop strategies
- Close calls with frustration meter
- Players immediately want to try again

## Code Structure Preview

```gdscript
# baby_system.gd - The entire baby logic in one script
extends Node

signal baby_picked_up()
signal baby_put_down()
signal baby_crying()

enum BabyState {CALM, FUSSING, CRYING, HELD}
var state: BabyState = BabyState.CALM
var fuss_meter: float = 0.0
var calm_timer: float = 0.0

func _ready():
    calm_timer = CALM_DURATION

func _process(delta):
    match state:
        BabyState.CALM:
            calm_timer -= delta
            if calm_timer <= 0:
                fuss_meter += FUSS_RATE * delta
                if fuss_meter >= 50:
                    state = BabyState.FUSSING
                if fuss_meter >= 100:
                    state = BabyState.CRYING
                    baby_crying.emit()
        
        BabyState.CRYING:
            GameManager.frustration += FRUSTRATION_RATE * delta

func pick_up():
    state = BabyState.HELD
    fuss_meter = 0
    baby_picked_up.emit()

func put_down():
    state = BabyState.CALM
    calm_timer = CALM_DURATION
    baby_put_down.emit()
```

## Next Steps After Core Loop Works

Only after players find the basic loop fun:

1. **Tiny Addition 1**: Baby giggles when picked up (pure polish)
2. **Tiny Addition 2**: Coffee steam animation (pure polish)
3. **Tiny Addition 3**: Different baby cry intensities (game feel)

NOT:
- More meters
- More tasks
- More rooms
- Story elements
- Other characters

## The Development Mantra

**"Is this making the core loop better, or am I adding complexity?"**

If it's not making the 30-second loop more fun, don't add it.