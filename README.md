# Fuzzy

Fuzzy string matching library for Elixir. Find similar strings, detect typos, and match user input against known values.

## Features

- **Multiple similarity metrics**: Levenshtein distance, Jaro similarity, and Jaro-Winkler similarity
- **High-level matching functions**: `ratio/3`, `partial_ratio/3`, `token_sort_ratio/3`, `token_set_ratio/3`
- **Full Unicode support**: Works with accented characters, CJK, emojis, and more
- **Zero dependencies**: Pure Elixir implementation

## Installation

Add `fuzzy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fuzzy, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic similarity ratio

```elixir
Fuzzy.ratio("hello", "hallo")
# => 0.8

Fuzzy.ratio("paper", "paper")
# => 1.0
```

### Using different metrics

```elixir
# Default: Levenshtein distance
Fuzzy.ratio("dwayne", "duane")
# => 0.67

# Jaro-Winkler (better for names)
Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler)
# => 0.84
```

### Partial matching

Find the best partial match when one string is a substring of another:

```elixir
Fuzzy.partial_ratio("yankees", "new york yankees")
# => 1.0
```

### Token-based matching

Handle word reordering and duplicates:

```elixir
# Token sort: ignores word order
Fuzzy.token_sort_ratio("New York Mets", "Mets New York")
# => 1.0

# Token set: handles duplicates and extra words
Fuzzy.token_set_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear")
# => 1.0
```

## Available Metrics

| Metric | Best for | Function |
|--------|----------|----------|
| `:levenshtein` | General purpose | Edit distance |
| `:jaro` | Short strings | Character matching |
| `:jaro_winkler` | Names | Jaro + prefix bonus |

## License

MIT
