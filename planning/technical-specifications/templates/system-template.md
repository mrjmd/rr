# System Specification: [SYSTEM NAME]

## Reality Check
**Complexity Rating**: [1-5] ⚠️  
**Estimated Implementation Time**: [X days/weeks] (multiply your estimate by 3)  
**Developer Experience Required**: [Beginner/Intermediate/Advanced]  
**Is This Actually Needed for MVP?**: [YES/NO]  

## One-Sentence Description
[If you can't describe it in one sentence, it's too complex]

## Problem This Solves
[What player experience issue does this address?]
[Could we solve this problem more simply?]

## Success Criteria
- [ ] Criterion 1 (measurable and specific)
- [ ] Criterion 2 (measurable and specific)
- [ ] Criterion 3 (measurable and specific)

## Anti-Requirements (What This System Does NOT Do)
- Does NOT [scope limit 1]
- Does NOT [scope limit 2]
- Does NOT [scope limit 3]

## Technical Design

### Core Components
```gdscript
# Pseudocode or actual GDScript showing the main structure
# Keep this SIMPLE - under 50 lines
```

### Data Structures
```gdscript
# What data needs to be tracked?
# Keep it minimal
```

### Dependencies
- **Required Systems**: [List systems that MUST exist first]
- **Optional Integrations**: [Nice-to-haves]

## Simplest Possible Implementation
[Describe the absolute minimum version that would work]
[This is what you should actually build first]

## Complexity Creep Warnings
- ⚠️ Watch out for: [Common way this could become too complex]
- ⚠️ Watch out for: [Another complexity trap]
- ⚠️ Watch out for: [Third complexity trap]

## Testing Strategy

### Manual Testing (5 minutes or less)
1. Step 1 to verify basic functionality
2. Step 2 to verify basic functionality
3. Step 3 to verify basic functionality

### Edge Cases
- What happens if [edge case 1]?
- What happens if [edge case 2]?
- What happens if [edge case 3]?

### Performance Benchmarks
- Must maintain 60 FPS with [specific load]
- Memory usage under [X] MB
- Response time under [X] ms

## Alternatives Considered

### Simpler Alternative 1
**What**: [Description]
**Why Rejected**: [Reason]

### Simpler Alternative 2
**What**: [Description]
**Why Rejected**: [Reason]

### Even Simpler Alternative
**What**: [Description]
**Why Rejected**: [If you rejected this, reconsider]

## Implementation Phases

### Phase 1: Proof of Concept (1-2 days)
- [ ] Basic functionality working
- [ ] Can be tested in isolation
- [ ] No polish needed

### Phase 2: Integration (2-3 days)
- [ ] Connected to other systems
- [ ] Basic error handling
- [ ] Save/load support (if needed)

### Phase 3: Polish (Optional, not for MVP)
- [ ] Animations/juice
- [ ] Sound effects
- [ ] Edge case handling

## Risk Assessment

### High Risks
- **Risk 1**: [Description] | **Mitigation**: [How to handle]
- **Risk 2**: [Description] | **Mitigation**: [How to handle]

### Medium Risks
- **Risk 1**: [Description] | **Mitigation**: [How to handle]

## Questions to Answer Before Starting
1. Could this be a simple boolean instead of a complex system?
2. What's the player-facing impact if we don't build this?
3. Could we fake this with scripted sequences instead?
4. Is there a Godot addon that already does this?
5. Will players actually notice/care about this feature?

## Final Sanity Check
- [ ] This can be explained to a non-developer in 30 seconds
- [ ] This can be implemented in less than a week
- [ ] This can be tested without other systems
- [ ] This actually makes the game more fun
- [ ] This is the simplest solution that could work

**If you can't check all five boxes, this spec needs simplification.**