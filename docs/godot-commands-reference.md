# Godot Commands Reference

## Complete Command List

### Editor & Development
```bash
# macOS Godot path
GODOT="/Applications/Godot.app/Contents/MacOS/Godot"

# Launch editor
$GODOT --editor --path /Users/matt/Projects/randos-reservoir

# Run game normally
$GODOT --path /Users/matt/Projects/randos-reservoir

# Run game with debug output captured
$GODOT --verbose --path /Users/matt/Projects/randos-reservoir --log-file debug.log

# Run headless (no display)
$GODOT --headless --path /Users/matt/Projects/randos-reservoir

# Run with remote debugging
$GODOT --remote-debug tcp://localhost:6007 --path /Users/matt/Projects/randos-reservoir

# Run specific scene
$GODOT --path /Users/matt/Projects/randos-reservoir res://scenes/test_scene.tscn

# Check project without running
$GODOT --headless --quit --check-only

# Import assets and quit
$GODOT --headless --editor --quit-after 2
```

### Build & Export
```bash
# Debug build
$GODOT --headless --export-debug "macOS" builds/debug.app
$GODOT --headless --export-debug "Windows Desktop" builds/windows/game.exe

# Release build
$GODOT --headless --export-release "macOS" builds/release.app
$GODOT --headless --export-release "Windows Desktop" builds/windows/game.exe

# Run tests
godot -s addons/gut/gut_cmdln.gd -gtest=res://tests/
```

### Testing & Automation
```bash
# Run game with automated input simulation
$GODOT --path /Users/matt/Projects/randos-reservoir --script res://tests/automation.gd

# Run with performance profiling
$GODOT --path /Users/matt/Projects/randos-reservoir --profiling --gpu-profile

# Capture frame-by-frame output
$GODOT --path /Users/matt/Projects/randos-reservoir --quit-after 300 --log-file frame_log.txt

# Run automated test scene
$GODOT --path /Users/matt/Projects/randos-reservoir --script res://tests/automated_test_runner.gd
```

### Debug Output Analysis
```bash
# Parse Godot debug output
$GODOT --verbose --path /Users/matt/Projects/randos-reservoir 2>&1 | tee debug.log

# Filter for specific messages
$GODOT --verbose --path /Users/matt/Projects/randos-reservoir 2>&1 | grep -E "(ERROR|WARNING)"

# Monitor real-time performance
$GODOT --path /Users/matt/Projects/randos-reservoir --profiling 2>&1 | grep "FPS"

# Extract FPS data
grep "FPS:" performance.log | awk '{print $2}' > fps_data.txt

# Monitor memory usage
$GODOT --verbose --path /Users/matt/Projects/randos-reservoir 2>&1 | grep -i "memory"
```

### Screenshot Methods

#### Method 1: Automated Screenshot Script
```gdscript
# automation_screenshot.gd - Run with --script flag
extends SceneTree

func _init():
    await get_tree().process_frame
    await get_tree().create_timer(1.0).timeout
    
    var viewport = get_root()
    var image = viewport.get_texture().get_image()
    image.save_png("res://screenshots/automated_capture.png")
    print("Screenshot captured")
    quit()
```

#### Method 2: External Screenshot via OS
```bash
# macOS screenshot during game run
screencapture -x screenshot.png

# Take screenshot after delay
sleep 2 && screencapture -x game_screenshot.png

# Capture specific window (requires window ID)
screencapture -l$(osascript -e 'tell app "Godot" to id of window 1') godot_window.png
```

### Remote Control via TCP
```gdscript
# Add to autoload for external control
extends Node

var tcp_server: TCPServer
var control_port = 9999

func _ready():
    tcp_server = TCPServer.new()
    tcp_server.listen(control_port)

func _process(_delta):
    if tcp_server.is_connection_available():
        var client = tcp_server.take_connection()
        var command = client.get_string(client.get_available_bytes())
        
        match command.strip_edges():
            "screenshot":
                take_screenshot()
            "quit":
                get_tree().quit()
            "pause":
                get_tree().paused = true
            "resume":
                get_tree().paused = false
```