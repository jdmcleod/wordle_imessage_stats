# GitHub Copilot Instructions

## General Guidelines

- **Do NOT create README files or other explanatory documentation files** unless explicitly requested
- **Avoid unnecessary comments in code** - write self-explanatory code instead
- Only add comments when the logic is genuinely complex or non-obvious

## Project Context

This is a Ruby-based project for analyzing Wordle game statistics from a group chat. It parses chat logs and CSV data to generate statistics, identify trends, and display results.

## Code Style

- Follow Ruby conventions and best practices
- Use meaningful variable and method names that make the code self-documenting
- Keep methods focused and concise
- Prefer descriptive naming over explanatory comments

## Architecture

- **Scripts** (`scripts/`): Executable Ruby scripts for specific tasks
- **Source** (`source/`): Core classes and modules
- **Data** (`data/`): CSV files, JSON caches, and chat logs
- **Web** (root): HTML files for visualizations

## Key Classes

- `Wordle`: Represents a single Wordle game result
- `WordleStats`: Main statistics calculator
- `WordleCsvParser`: Handles CSV reading/writing with metadata preservation
- `WordleChatParser`: Parses chat.txt for Wordle results
- `HistoryManager`: Manages historical data

## Data Integrity

- **CSV metadata must be preserved** when updating `wordle_results.csv`
- Use `parse_with_metadata()` and `save_with_metadata()` for CSV operations
- Never modify existing rows - only append new ones
- Metadata includes: NYT averages, chat averages, best/luckiest guess flags

## Testing

- RSpec is used for testing
- Test files go in `spec/`
- Run tests with `rspec`

## Dependencies

- Managed via Bundler (Gemfile)
- Use `bundle install` for setup
- Add new gems to Gemfile when needed

