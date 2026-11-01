my $global;

class Text::Inflector {
  has %!plural-of-irregular;
  has %!singular-of-irregular;
  has %!uncountable;
  has @!plural-rules;
  has @!singular-rules;
  has %!acronym-of;
  has Bool $!is-frozen = False;

  submethod TWEAK {
    self!load-english;
  }

  method inflections(&block) {
    return $global.inflections(&block) unless self.DEFINITE;

    self!refuse-when-frozen;
    block(self);

    self
  }

  method irregular(Str:D $singular, Str:D $plural) {
    return $global.irregular($singular, $plural) unless self.DEFINITE;

    self!refuse-when-frozen;
    self!add-irregular($singular, $plural);

    self
  }

  method uncountable(*@words) {
    return $global.uncountable(|@words) unless self.DEFINITE;

    self!refuse-when-frozen;
    self!add-uncountable(|@words);

    self
  }

  method plural(Regex:D $rule, Str:D $replacement) {
    return $global.plural($rule, $replacement) unless self.DEFINITE;

    self!refuse-when-frozen;
    @!plural-rules.unshift: $rule => $replacement;

    self
  }

  method singular(Regex:D $rule, Str:D $replacement) {
    return $global.singular($rule, $replacement) unless self.DEFINITE;

    self!refuse-when-frozen;
    @!singular-rules.unshift: $rule => $replacement;

    self
  }

  method acronym(Str:D $word) {
    return $global.acronym($word) unless self.DEFINITE;

    self!refuse-when-frozen;
    %!acronym-of{$word.lc} = $word;

    self
  }

  method freeze {
    return $global.freeze unless self.DEFINITE;

    $!is-frozen = True unless $!is-frozen;

    self
  }

  method is-frozen(--> Bool) {
    return $global.is-frozen unless self.DEFINITE;

    $!is-frozen
  }

  method pluralize(Str:D $word --> Str) {
    return $global.pluralize($word) unless self.DEFINITE;

    self.freeze;
    self!inflect($word, %!plural-of-irregular, @!plural-rules)
  }

  method singularize(Str:D $word --> Str) {
    return $global.singularize($word) unless self.DEFINITE;

    self.freeze;
    self!inflect($word, %!singular-of-irregular, @!singular-rules)
  }

  method camelize(Str:D $name --> Str) {
    return $global.camelize($name) unless self.DEFINITE;

    self.freeze;
    $name.split('-', :skip-empty).map({ %!acronym-of{.lc} // .tc }).join
  }

  method classify(Str:D $name --> Str) {
    return $global.classify($name) unless self.DEFINITE;

    self.camelize(self.singularize($name))
  }

  method underscore(Str:D $class-name --> Str) {
    return $global.underscore($class-name) unless self.DEFINITE;

    self.freeze;

    my $word = $class-name.split('::').first(:end).trans('-' => '_');

    for %!acronym-of.values.sort(-*.chars) -> $acronym {
      $word = $word.subst(/ $acronym /, -> $match {
        my $before = $match.from > 0 && $word.substr($match.from - 1, 1) ~~ /<[A..Za..z0..9]>/;
        my $after  = $word.substr($match.to, 1) ~~ /<[A..Z]>/;

        ($before ?? '_' !! '') ~ $acronym.lc ~ ($after ?? '_' !! '')
      }, :g);
    }

    $word = $word.subst(/ (<[A..Z0..9]>+) (<[A..Z]><[a..z]>) /, -> $match { "$match[0]_$match[1]" }, :g);
    $word = $word.subst(/ (<[a..z0..9]>) (<[A..Z]>) /, -> $match { "$match[0]_$match[1]" }, :g);

    $word.lc
  }

  method tableize(Str:D $class-name --> Str) {
    return $global.tableize($class-name) unless self.DEFINITE;

    self.pluralize(self.underscore($class-name))
  }

  method foreign-key(Str:D $class-name --> Str) {
    return $global.foreign-key($class-name) unless self.DEFINITE;

    self.underscore($class-name) ~ '_id'
  }

  method !refuse-when-frozen {
    die 'Inflection rules are frozen: add rules before the first lookup or freeze'
      if $!is-frozen;
  }

  method !add-irregular(Str:D $singular, Str:D $plural) {
    %!uncountable{$singular.lc}:delete;
    %!uncountable{$plural.lc}:delete;

    %!plural-of-irregular{$singular.lc}   = $plural.lc;
    %!plural-of-irregular{$plural.lc}     = $plural.lc;
    %!singular-of-irregular{$plural.lc}   = $singular.lc;
    %!singular-of-irregular{$singular.lc} = $singular.lc;
  }

  method !add-uncountable(*@words) {
    %!uncountable{.lc} = True for @words;
  }

  method !inflect(Str:D $word, %irregular, @rules --> Str) {
    my $cut  = max($word.rindex('-') // -1, $word.rindex('_') // -1);
    my $head = $word.substr(0, $cut + 1);
    my $last = $word.substr($cut + 1);

    return $word unless $last.chars;
    return $word if %!uncountable{$last.lc}:exists;

    with %irregular{$last.lc} -> $replacement {
      my $is-capitalized = $last.substr(0, 1) ne $last.substr(0, 1).lc;

      return $head ~ ($is-capitalized ?? $replacement.tc !! $replacement);
    }

    for @rules -> $rule {
      my $match = $last.match($rule.key);
      next unless $match;

      my $replaced = $rule.value.subst(/ '$' (\d) /, -> $placeholder { ~($match[+$placeholder[0]] // '') }, :g);

      return $head ~ $last.substr(0, $match.from) ~ $replaced ~ $last.substr($match.to);
    }

    $word
  }

  method !load-english {
    my @plurals =
      rx:i/ $ /                              => 's',
      rx:i/ s $ /                            => 's',
      rx:i/ ^ (ax | test) is $ /             => '$0es',
      rx:i/ (octop | vir) us $ /             => '$0i',
      rx:i/ (octop | vir) i $ /              => '$0i',
      rx:i/ (alias | status) $ /             => '$0es',
      rx:i/ (bu) s $ /                       => '$0ses',
      rx:i/ (buffal | tomat) o $ /           => '$0oes',
      rx:i/ (<[ti]>) um $ /                  => '$0a',
      rx:i/ (<[ti]>) a $ /                   => '$0a',
      rx:i/ sis $ /                          => 'ses',
      rx:i/ [ (<-[f]>) fe | (<[lr]>) f ] $ / => '$0ves',
      rx:i/ (hive) $ /                       => '$0s',
      rx:i/ (<-[aeiouy]> | qu) y $ /         => '$0ies',
      rx:i/ (x | ch | ss | sh) $ /           => '$0es',
      rx:i/ (matr | vert | ind) [ix | ex] $ / => '$0ices',
      rx:i/ ^ (m | l) ouse $ /               => '$0ice',
      rx:i/ ^ (m | l) ice $ /                => '$0ice',
      rx:i/ ^ (ox) $ /                       => '$0en',
      rx:i/ ^ (oxen) $ /                     => '$0',
      rx:i/ (quiz) $ /                       => '$0zes';

    my @singulars =
      rx:i/ s $ /                                                      => '',
      rx:i/ (ss) $ /                                                   => '$0',
      rx:i/ (n) ews $ /                                                => '$0ews',
      rx:i/ (<[ti]>) a $ /                                             => '$0um',
      rx:i/ (analy | ba | diagno | parenthe | progno | synop | the) [sis | ses] $ / => '$0sis',
      rx:i/ (<-[f]>) ves $ /                                           => '$0fe',
      rx:i/ (hive) s $ /                                               => '$0',
      rx:i/ (tive) s $ /                                               => '$0',
      rx:i/ (<[lr]>) ves $ /                                           => '$0f',
      rx:i/ (<-[aeiouy]> | qu) ies $ /                                 => '$0y',
      rx:i/ (s) eries $ /                                              => '$0eries',
      rx:i/ (m) ovies $ /                                              => '$0ovie',
      rx:i/ (x | ch | ss | sh) es $ /                                  => '$0',
      rx:i/ ^ (m | l) ice $ /                                          => '$0ouse',
      rx:i/ (bus) [es]? $ /                                            => '$0',
      rx:i/ (o) es $ /                                                 => '$0',
      rx:i/ (shoe) s $ /                                               => '$0',
      rx:i/ (cris | test) [is | es] $ /                                => '$0is',
      rx:i/ ^ (a) x <[ie]> s $ /                                       => '$0xis',
      rx:i/ (octop | vir) [us | i] $ /                                 => '$0us',
      rx:i/ (alias | status) [es]? $ /                                 => '$0',
      rx:i/ ^ (ox) en /                                                => '$0',
      rx:i/ (vert | ind) ices $ /                                      => '$0ex',
      rx:i/ (matr) ices $ /                                            => '$0ix',
      rx:i/ (quiz) zes $ /                                             => '$0',
      rx:i/ (database) s $ /                                           => '$0';

    @!plural-rules.unshift:   $_ for @plurals;
    @!singular-rules.unshift: $_ for @singulars;

    self!add-irregular(|$_) for
      <person people>, <man men>, <woman women>, <child children>,
      <sex sexes>, <move moves>, <zombie zombies>,
      <foot feet>, <tooth teeth>, <goose geese>;

    self!add-uncountable(<equipment information rice money species series fish sheep deer jeans police>);
  }
}

$global = Text::Inflector.new;
