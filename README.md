# Fuzzy

Fuzzy string matching library for Elixir. Find similar strings, detect typos, and match user input against known values.

## Features

- **High-level matching functions**: `ratio/3`, `partial_ratio/3`, `token_sort_ratio/3`, `token_set_ratio/3`
- **Multiple similarity metrics**: Sequence matcher similarity, Levenshtein distance, Jaro similarity, and Jaro-Winkler similarity
- **Flexible token matching**: Use `:ratio_fn` option to switch between full and partial matching
- **Full Unicode support**: Works with accented characters, asian graphemes, emojis, and more
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
# Default: sequence_matcher (Ratcliff/Obershelp)
Fuzzy.ratio("dwayne", "duane")
# => 0.73

# Jaro-Winkler (better for names)
Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler)
# => 0.84

# Levenshtein (edit distance)
Fuzzy.ratio("dwayne", "duane", metric: :levenshtein)
# => 0.82
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

# Use partial matching for substring tolerance
Fuzzy.token_sort_ratio("def abc", "ghi abc def", ratio_fn: :partial_ratio)
# => 1.0

Fuzzy.token_set_ratio("The New York Mets", "Mets New York", ratio_fn: :partial_ratio)
# => 1.0
```

## Available Metrics

| Metric | Best for | Function |
|--------|----------|----------|
| `:sequence_matcher` | Default | Ratcliff/Obershelp algorithm |
| `:levenshtein` | General purpose | Edit distance |
| `:jaro` | Short strings | Character matching |
| `:jaro_winkler` | Names | Jaro + prefix bonus |

### Metric-specific options

**Levenshtein** supports a `:scaling` option to control how similarity is calculated:

```elixir
# Default: :sum_lengths - similarity = (len1 + len2 - distance) / (len1 + len2)
Fuzzy.ratio("hello", "hallo", metric: :levenshtein)
# => 0.9

# Alternative: :max_length - similarity = 1 - distance / max(len1, len2)
Fuzzy.ratio("hello", "hallo", metric: :levenshtein, scaling: :max_length)
# => 0.8
```

**Jaro-Winkler** supports prefix tuning options:

```elixir
# Default: prefix_weight=0.1, prefix_length=4
Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler)
# => 0.84

# Custom prefix weight (higher = more bonus for common prefix)
Fuzzy.ratio("dwayne", "duane", metric: :jaro_winkler, prefix_weight: 0.2)
# => 0.86

# Custom max prefix length to consider (useful for long common prefixes)
Fuzzy.ratio("telephone", "telephony", metric: :jaro_winkler)
# => 0.96

Fuzzy.ratio("telephone", "telephony", metric: :jaro_winkler, prefix_length: 2)
# => 0.94
```

## Options

All functions accept these common options:

| Option | Default | Description |
|--------|---------|-------------|
| `:normalize` | `false` | If `true` : lowercase and remove non-alphanumeric characters |
| `:metric` | `:sequence_matcher` | Similarity algorithm to use |

Token functions (`token_sort_ratio`, `token_set_ratio`) also accept:

| Option | Default | Description |
|--------|---------|-------------|
| `:ratio_fn` | `:ratio` | Use `:partial_ratio` for substring tolerance |

## License

MIT
