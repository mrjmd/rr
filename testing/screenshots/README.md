# Screenshot Organization Structure

This directory contains organized testing screenshots from Rando's Reservoir development.

## Directory Structure

```
testing/screenshots/
├── current/                    # Current session screenshots
│   ├── session-4/             # Session 4 screenshots
│   └── working/               # Temporary working screenshots
├── archive/                   # Historical screenshots organized by session
│   ├── session-1/            # Week 1-2 development
│   ├── session-2/            # Week 1-2 completion
│   ├── session-3/            # Week 3-4 fade transitions
│   └── README.md             # Archive index
├── automated/                 # Automated testing screenshots
│   ├── fade-transitions/     # Fade system tests
│   ├── ui-components/        # UI component tests
│   └── integration/          # Integration test captures
└── reference/                 # Reference images for comparison
    ├── ui-layouts/           # UI layout references
    └── transitions/          # Transition references
```

## Screenshot Naming Convention

### Manual Screenshots
- Format: `{feature}_{test-case}_{timestamp}.png`
- Example: `fade_transition_cyan-to-black_20250901-1720.png`

### Automated Screenshots  
- Format: `auto_{system}_{step}_{timestamp}.png`
- Example: `auto_fade_before-transition_20250901-1720.png`

### Session Screenshots
- Format: `session{N}_{feature}_{description}.png`
- Example: `session3_fade_working-transition.png`

## Usage Guidelines

1. **Current Session**: Use `current/session-4/` for active work
2. **Archive**: Move completed session screenshots to `archive/session-N/`
3. **Automated**: System-generated screenshots go to `automated/{system}/`
4. **Reference**: Keep comparison images in `reference/{category}/`

## Integration with Scripts

Updated screenshot paths for Godot scripts:
- Development: `res://testing/screenshots/current/working/`
- Automated: `res://testing/screenshots/automated/`
- Archive: `res://testing/screenshots/archive/session-N/`