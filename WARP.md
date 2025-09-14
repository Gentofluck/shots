# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
This is a Flutter desktop application called "shots" - a cross-platform screenshot tool with annotation capabilities. The app runs natively on Windows, Linux, and macOS, providing system-wide hotkey support for capturing and editing screenshots.

## Development Commands

### Basic Flutter Commands
- **Build for development**: `flutter run`
- **Build release**: `flutter build windows/linux/macos` (depending on platform)
- **Install dependencies**: `flutter pub get`
- **Analyze code**: `flutter analyze`
- **Run tests**: `flutter test`
- **Run single test**: `flutter test test/widget_test.dart`

### Platform-Specific Testing
- **Windows**: `flutter run -d windows`
- **Linux**: `flutter run -d linux`
- **macOS**: `flutter run -d macos`

### Code Quality
- **Lint**: Uses `flutter_lints` package with standard Flutter linting rules
- **Format code**: `dart format .`

## Architecture Overview

### Core Application Flow
The app follows a state-based navigation pattern with three main pages:
1. **AuthPage**: User authentication with shots API
2. **HomePage**: Hotkey configuration and settings
3. **ScreenshotPage**: Screenshot capture and editing interface

### Key Architecture Components

#### State Management
- Uses `StatefulWidget` pattern with manual state management
- Global application state managed in `_MyAppState` (main.dart)
- Page routing handled through string-based page switching

#### Screenshot System
- **ScreenshotService**: Handles screen capture using custom `screen_capturer` package
- **Region capture**: Interactive area selection for screenshots
- **Clipboard integration**: Automatic copying of captured content

#### Drawing/Annotation System
The app features a sophisticated vector-based drawing system:

- **DrawingService**: Central service managing drawing history and coordinating tool operations
- **Tool Strategy Pattern**: Each drawing tool is implemented as a separate class:
  - `PenTool`: Freehand drawing with stroke smoothing
  - `TextTool`: Text annotation with live editing
  - `FigureTool`: Geometric shapes (rectangle, oval, arrow)
  - `EraserTool`: Element removal by hit detection
  - `MoveTool`: Translation of existing elements
  - `CopyTool`: Region copying from screenshot
  - `TextNumTool`: Sequential numbering annotations
- **Entity Hierarchy**:
  - `DrawableEntity` (abstract base)
  - `GraphicEntity` (visible entities with translations/transformations)  
  - `VectorEntity` (drawable vectors like strokes, text, shapes)
  - Concrete types: `Stroke`, `TextStroke`, `FigureStroke`, `CopiedRegion`

#### Drawing Features
- **Tool Architecture**: Clean separation of concerns using strategy pattern
- **Undo/Redo**: Full history management with `StrokeChange` tracking
- **Tools**: Pen, text, shapes (rectangle, oval, arrow), eraser, region copying
- **Transformations**: Move, scale, and modify existing annotations
- **Text Editing**: Live text input with font sizing and positioning
- **Layer System**: Z-order management for overlapping elements

#### API Integration
- **ShotsClient**: HTTP client for authentication and image upload
- **Endpoints**: Login, token validation, and screenshot upload to `shots.m18.ru`
- **Token Management**: Persistent storage using `shared_preferences`

#### Desktop Integration
- **Window Management**: Custom window sizing, hiding, and focus control
- **Hotkeys**: Global hotkey registration for screenshot capture and upload
- **System Tray**: Background operation with tray icon support
- **Cross-platform**: Conditional behavior for Windows/Linux vs macOS

### Critical Dependencies
- `screen_capturer`: Custom local package for screen capture functionality
- `window_manager`: Desktop window control and management
- `hotkey_manager`: Global hotkey registration and handling
- `system_tray`: System tray integration for background operation

### Data Flow
1. User configures hotkeys in HomePage → saves to SharedPreferences
2. App registers global hotkeys and hides to background
3. Hotkey trigger → captures screen region → shows editor
4. User annotates → combines screenshot with drawings → uploads via API
5. URL copied to clipboard, app returns to background

### Custom Packages
The project includes a modified `screen_capturer` package located at `lib/packages/screen_capturer-main/` for specialized screenshot functionality.

### Architecture Notes
- **Drawing System Refactoring**: The `DrawingService` has been refactored from a monolithic `addPoint` method to use the Strategy pattern with individual tool classes
- **Tool Factory**: `ToolFactory` creates appropriate tool instances based on tool name and current drawing settings
- **Cleaner Separation**: Each tool handles its own logic for start/move/end interactions, making the system more maintainable and testable
- **State Management**: DrawingService now focuses on history management while tools handle drawing behavior

### Testing
- Basic widget tests available in `test/widget_test.dart`
- Test the main app widget structure and navigation flow
- Note: The current test appears to be template code and may need updates to match actual app functionality
- **Tool Testing**: Each drawing tool can now be unit tested independently
