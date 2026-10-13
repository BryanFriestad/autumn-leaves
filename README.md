# Autumn Leaves Solitaire

A Flutter-based solitaire card game for Android with offline play support and future server integration capabilities.

## Game Rules

1. **Card Movement**: Move any card from the top of one pile onto the top of another pile if the suits match and the card being moved is of a lower number (Aces are low).

2. **Face-Down Cards**: When there are no more face-up cards on a pile, turn the topmost face-down card face-up.

3. **Empty Piles**: Any card can be placed in an empty pile.

4. **Block Movement**: A descending run of cards in the same suit can be moved as a block.

5. **Dealing**: At any time you may deal out the next 6 of the left-over cards: one onto each pile (even if a pile is empty).

6. **Winning**: The game is won if each of the four suits is gathered together into a run from King down to Ace.

**Initial Deal**: 22 cards are dealt into 6 piles:
- Columns 1, 2, 5, 6: 4 cards each (top card face-up)
- Columns 3, 4: 3 cards each (top card face-up)
- Remaining 30 cards go to the stock pile

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── card.dart            # Card model (Suit, Rank)
│   ├── pile.dart            # Pile model (collection of cards)
│   └── game_state.dart      # Game state management
├── logic/
│   └── game_rules.dart      # Game rules and validation logic
├── controllers/
│   └── game_controller.dart # State management with Provider
├── widgets/
│   ├── card_widget.dart     # Card UI component
│   └── pile_widget.dart     # Pile UI component
├── screens/
│   └── game_screen.dart     # Main game screen
└── services/
    └── server_service.dart  # Server integration interface (future-proof)
```

## Running the App

### Prerequisites
- Flutter SDK (3.10.8 or higher)
- Android Studio / VS Code with Flutter extension

### Setup
```bash
cd autumn_leaves
flutter pub get
```

### Run on Windows (for testing)
```bash
flutter run -d windows
```

### Run on Android Device/Emulator
```bash
flutter run
```

### Build for Android
```bash
flutter build apk
```

## Future Server Integration

The project includes a `ServerService` abstract class that defines the interface for future server features:

- **Solvable Games**: Fetch a list of pre-solved game configurations
- **Leaderboard**: Submit scores and view rankings
- **Next Solvable Game**: Get the next solvable game to play

Currently, a `MockServerService` implementation is provided for offline play. To enable server features:

1. Implement the `ServerService` interface with your API calls
2. Inject the real service instead of the mock in the game controller
3. Add UI elements to display server data (leaderboard, solvable games list, etc.)

## Game Features

- **Offline Play**: Fully functional without internet connection
- **Touch Controls**: Tap to select cards, tap destination to move
- **Visual Feedback**: Selected cards highlighted with yellow border
- **Move Counter**: Tracks number of moves made
- **Stock Counter**: Shows remaining cards in stock
- **Win Detection**: Automatically detects when game is won
- **Deal Button**: Deal 6 cards when stock has enough cards

## Customization

### Card Sizing
Adjust card dimensions in `card_widget.dart`:
```dart
const CardWidget(
  width: 60,  // Default width
  height: 90, // Default height
)
```

### Theme Colors
Modify colors in `game_screen.dart`:
```dart
backgroundColor: Colors.green[700], // Table color
```

## License

This project is created for personal use.
