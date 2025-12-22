# Daily Weekly Todo - World of Warcraft Addon

![Release](https://img.shields.io/github/v/release/yourusername/daily-weekly-todo)
![Downloads](https://img.shields.io/github/downloads/yourusername/daily-weekly-todo/total)
![License](https://img.shields.io/github/license/yourusername/daily-weekly-todo)

A customizable daily and weekly todo list addon for World of Warcraft retail with checkbox-style completion tracking.

## Download

### Automatic Installation (Recommended)
- **Curse/Overwolf**: Search for "Daily Weekly Todo" in the app
- **WowUp**: Search for "Daily Weekly Todo" in the app
- **Ajour**: Add this repository URL to track releases

### Manual Installation
1. Go to the [Releases page](https://github.com/yourusername/daily-weekly-todo/releases)
2. Download the latest `DailyWeeklyTodo-latest.zip` file
3. Extract to your `World of Warcraft/Interface/AddOns/` directory
4. Restart WoW or type `/reload`

## Features

- **Daily & Weekly Todos**: Separate lists for daily and weekly tasks
- **Automatic Reset**: Daily todos reset at server midnight, weekly todos reset according to your server region
- **Server Region Detection**: Automatically detects your server region (US, EU, KR, TW, CN) for accurate weekly reset times
- **Checkbox Interface**: Clean, intuitive checkbox-style UI
- **Progress Tracking**: Shows completion progress for both daily and weekly todos
- **Customizable**: Add your own custom todos
- **Persistent**: Saves your todos and completion status
- **Movable Window**: Drag the window to your preferred location

## Manual Development Setup

If you want to modify or contribute to the addon:

1. Clone this repository: `git clone https://github.com/yourusername/daily-weekly-todo.git`
2. Copy the addon files to your `World of Warcraft/Interface/AddOns/DailyWeeklyTodo/` directory
3. Restart WoW or type `/reload`
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a new Pull Request

## Releasing

Releases are automatically created using GitHub Actions:

1. **Tag Release**: Push a version tag (e.g., `v1.0.1`) to trigger an automatic release
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

2. **Manual Release**: Use GitHub Actions "Create Release" workflow with manual trigger

Each release automatically:
- Updates the version in the `.toc` file
- Creates a properly formatted addon zip file
- Generates checksums for verification
- Creates GitHub release with download links

## Support

If you encounter any issues or have suggestions:
- [Create an issue](https://github.com/yourusername/daily-weekly-todo/issues) on GitHub
- Check existing issues for solutions
- Submit feature requests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.