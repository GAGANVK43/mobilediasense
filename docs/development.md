# Development Guide: DiaSense Mobile

## Coding Conventions
- Strictly follow lutter_lints.
- Maintain touch target dimensions >= 48px.
- Use AppSpacing, AppColors, and AppTypography design tokens.
- Separate all business logic into StateNotifiers.

## Testing Guidelines
- Run unit tests: lutter test test/unit/
- Run widget tests: lutter test test/widget/
- Analyze codebase: lutter analyze
