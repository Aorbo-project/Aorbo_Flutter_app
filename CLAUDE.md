# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (lint)
flutter analyze

# Build
flutter build apk           # Android APK
flutter build appbundle     # Android AAB
flutter build ios           # iOS
flutter build web           # Web
```

VSCode launch configs (`.vscode/launch.json`) provide debug, profile, and release run configurations.

## Architecture

### State Management: GetX
All controllers extend `GetxController` and live in `lib/controller/`. Reactive state uses `.obs`, `Rx<T>`, `RxBool`, `RxString`, etc. UI rebuilds wrap in `Obx(() => ...)`. Controllers are injected via `Get.find<ControllerName>()`.

Key controllers:
- `AuthController` — Firebase phone auth, OTP, JWT ID token management
- `TrekController` — Trek data, search, filtering
- `UserController` — User profile
- `ChatController` — Real-time Socket.IO chat
- `DashboardController` — Dashboard state

### Routing: GetX Named Routes
All 32 routes defined in `lib/routes/routes.dart`. Navigation uses `Get.toNamed('/route-name')` or `Get.to(Screen())`. Entry point is `/` (splash/login).

### Network Layer: Repository Pattern
`lib/repository/repository.dart` is a singleton Dio-based HTTP client. It handles:
- Bearer token auth (JWT from Firebase, stored in SharedPreferences)
- Request/response logging interceptors
- 40-second timeout
- Pre-request connectivity checks

`lib/repository/network_url.dart` holds all API endpoint constants.

`ChatRepository` in `lib/repository/chat_repository.dart` handles chat-specific API calls.

### Real-time: Socket.IO
`lib/services/socket_service.dart` manages the Socket.IO connection for the live chat feature.

### Authentication Flow
Firebase Phone Auth → OTP verification → Firebase ID token → stored via `SpUtil` (SharedPreferences wrapper) → sent as Bearer token in all API requests.

### UI Conventions
- **Responsive sizing: `sizer` package only** — always use `10.w`, `5.h`, `12.sp`; never mix with `MediaQuery.of(context).size.*` for layout dimensions
- The one valid exception: `ConstrainedBox(minHeight:)` inside `SafeArea` + `SingleChildScrollView` may use `MediaQuery` to compute available height minus system padding
- `MediaQuery` wrapping `TextField` to override `textScaler` is intentional and should not be replaced
- Font sizes come from `FontSize.*` constants in `lib/utils/screen_constants.dart` — do not use `.sp` directly for fonts
- Centralized styles: `lib/utils/app_theme.dart`, `lib/utils/app_text_styles.dart`, `lib/utils/app_dimensions.dart`, `lib/utils/common_colors.dart`
- Reusable widgets in `lib/widgets/` and `lib/utils/` (30+ common components)
- Lottie animations in `assets/animations/`, SVGs and PNGs in `assets/images/`

### Controller Registration Rules
- `AuthController` is registered **once** with `Get.put(AuthController(), permanent: true)` in `login_screen.dart`
- All other files must use `Get.find<AuthController>()` — never call `Get.put(AuthController(), ...)` again elsewhere
- `OTPController` uses `Get.find<AuthController>()` (fixed — was previously creating a duplicate)

### Models
Located in `lib/models/` organized by domain: `auth/`, `chat/`, `coupon_code/`, `dashboard/`, `dispute/`, `refund/`, `treaks/`, `user_profile/`. The main trek model (`trek_model.dart`) is large (~80KB).

## Key Integrations
- **Firebase:** Auth (phone OTP), Cloud Messaging (push notifications), App Check
- **Razorpay:** Payment gateway (`razorpay_flutter`)
- **Google Maps:** Location display (`google_maps_flutter`)
- **Socket.IO:** Real-time support chat

## Firebase Project
Project ID: `aorbo-trek-2a7dd`. Firebase config in `lib/firebase_options.dart`.

## Android Config
- Package: `com.eclipso.arobo_app`
- Min SDK: 26, Target/Compile SDK: 36

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
