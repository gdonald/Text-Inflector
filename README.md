# Text::Inflector

English plural, singular, and case inflection for Raku, with rules an app can
correct for its own words.

```raku
use Text::Inflector;

say Text::Inflector.pluralize('category');     # categories
say Text::Inflector.singularize('people');     # person
say Text::Inflector.camelize('line-item');     # LineItem
say Text::Inflector.classify('line-items');    # LineItem
say Text::Inflector.underscore('LineItem');    # line_item
say Text::Inflector.tableize('LeadStatus');    # lead_statuses
say Text::Inflector.foreign-key('LineItem');   # line_item_id
```

## Words

`pluralize` and `singularize` change only the last word of a compound. A dash
or an underscore separates words: `line-item` becomes `line-items`, and
`sales-person` becomes `sales-people`.

`camelize` and `classify` join dashed words. An underscore stays part of a
word, so `classify('user_exercises')` is `User_exercise`.

`underscore` drops a `::` namespace, so `App::Models::LineItem` becomes
`line_item`.

## Correcting a word

```raku
Text::Inflector.inflections: {
  .irregular('octopus', 'octopi');
  .uncountable('aircraft');
  .plural(rx:i/ ^ (cact) us $ /, '$0i');
  .singular(rx:i/ ^ (cact) i $ /, '$0us');
  .acronym('API');
}
```

| Rule | Effect |
| ---- | ------ |
| `irregular($singular, $plural)` | Maps the two words to each other in both directions. |
| `uncountable(*@words)` | Leaves the words unchanged in both directions. |
| `plural($regex, $replacement)` | Pluralizes a word the regex matches. `$0`, `$1`, ... in the replacement insert the captures. |
| `singular($regex, $replacement)` | Singularizes a word the regex matches. |
| `acronym($word)` | Keeps the word's case when camelizing (`api-keys` classifies to `APIKey`) and underscores it as one word (`APIKey` becomes `api_key`). |

Your rules are checked before the built-in rules, and a newer rule is checked
before an older one.

## Freezing

The first lookup freezes the rules, and so does `freeze`. Adding a rule after
that dies, so add your rules at startup, before anything inflects a name.

## Separate instances

Calls on the class use one set of process-wide rules. `Text::Inflector.new`
builds an inflector with the built-in rules and its own copy of any rules you
add, which keeps a test's rules out of the process-wide set:

```raku
my $inflector = Text::Inflector.new;
$inflector.inflections: { .irregular('cow', 'kine') };

say $inflector.pluralize('cow');         # kine
say Text::Inflector.pluralize('cow');    # cows
```

## Tests

```
./test.raku
```

## License

Artistic License 2.0.
