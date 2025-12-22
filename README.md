# Daily Weekly Todo - World of Warcraft Addon

A customizable daily and weekly todo list addon for World of Warcraft retail with checkbox-style completion tracking.

## Features

- **Daily & Weekly Todos**: Separate lists for daily and weekly tasks
- **Automatic Reset**: Daily todos reset at server midnight, weekly todos reset according to your server region
- **Server Region Detection**: Automatically detects your server region (US, EU, KR, TW, CN) for accurate weekly reset times
- **Checkbox Interface**: Clean, intuitive checkbox-style UI
- **Progress Tracking**: Shows completion progress for both daily and weekly todos
- **Customizable**: Add your own custom todos
- **Persistent**: Saves your todos and completion status
- **Movable Window**: Drag the window to your preferred location

## Installation

1. Download or clone this repository
2. Copy the `daily-weekly-todo` folder to your World of Warcraft `Interface/AddOns/` directory
3. Restart World of Warcraft or reload UI (`/reload`)
4. Enable the addon in the AddOns menu

## Usage

### Commands

- `/dwt` or `/dwt show` - Show the todo window
- `/dwt hide` - Hide the todo window  
- `/dwt reset` - Reset all todos (mark as uncompleted)
- `/dwt config` - Open configuration (coming soon)
- `/dailytodo` - Alternative command (same as `/dwt`)

### Interface

- **Checkboxes**: Click to mark todos as complete/incomplete
- **Add Todo**: Click "Add Todo" button to add new daily or weekly todos
- **Reset All**: Click "Reset All" button to mark all todos as uncompleted
- **Progress**: View completion progress (e.g., "2/5") next to each section header
- **Draggable**: Click and drag the title bar to move the window

### Default Todos

The addon comes with sample todos:

**Daily:**
- Complete 4 World Quests
- Do Emissary Quest  
- Complete Dungeon

**Weekly:**
- Complete Weekly Mythic+ Quest
- Complete World Boss
- Do 5 Mythic+ Dungeons

### Reset Times

- **Daily**: Resets at server midnight
- **Weekly**: Resets according to your server region:
  - **US**: Tuesday 10:00 AM EST (15:00 UTC)
  - **EU**: Wednesday 8:00 AM CET (07:00 UTC)
  - **KR/TW/CN**: Wednesday 8:00 AM local time (23:00 UTC previous day)

## Customization

You can add your own todos using the "Add Todo" button in the interface. Choose whether to add them as daily or weekly tasks.

## Data Storage

The addon uses SavedVariables to persist your data across sessions. Your todos and completion status are automatically saved.

## Compatibility

- **World of Warcraft**: Retail (The War Within - Interface 110002)
- **Dependencies**: Uses Ace3 libraries (AceAddon-3.0, AceConsole-3.0, AceEvent-3.0, AceDB-3.0)

## Future Features

- Configuration panel for customizing appearance
- Import/export todo lists
- Todo categories and priorities
- Notification system for incomplete todos
- Integration with in-game calendar

## Support

If you encounter any issues or have suggestions, please feel free to report them.

## License

This addon is open source and free to use and modify.