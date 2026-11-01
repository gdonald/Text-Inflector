# Changelog

All notable changes to Text::Inflector are recorded here. The format groups
entries under Added, Changed, Fixed, and Removed.

## Unreleased

### Added

- `pluralize`, `singularize`, `camelize`, `classify`, `underscore`,
  `tableize`, and `foreign-key`, with English plural, singular, irregular, and
  uncountable rules.
- `inflections`, `irregular`, `uncountable`, `plural`, `singular`, and
  `acronym` add an app's own rules, checked before the built-in rules.
- The first lookup or `freeze` freezes the rules. Adding a rule after that
  dies.
- Calls on the class use process-wide rules. `Text::Inflector.new` builds an
  inflector with its own copy.
