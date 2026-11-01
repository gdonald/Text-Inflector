use lib 'lib';
use BDD::Behave;
use Text::Inflector;

describe 'Text::Inflector', {
  let(:inflector, { Text::Inflector.new });

  describe 'pluralize', {
    it 'adds an s to a regular word', {
      expect(inflector.pluralize('lead')).to.eq('leads');
    }

    it 'turns a consonant y into ies', {
      expect(inflector.pluralize('category')).to.eq('categories');
    }

    it 'adds es after ss', {
      expect(inflector.pluralize('address')).to.eq('addresses');
    }

    it 'adds es to status', {
      expect(inflector.pluralize('status')).to.eq('statuses');
    }

    it 'turns a trailing fe into ves', {
      expect(inflector.pluralize('knife')).to.eq('knives');
    }

    it 'turns a trailing lf into lves', {
      expect(inflector.pluralize('shelf')).to.eq('shelves');
    }

    it 'uses the irregular plural of person', {
      expect(inflector.pluralize('person')).to.eq('people');
    }

    it 'uses the irregular plural of child', {
      expect(inflector.pluralize('child')).to.eq('children');
    }

    it 'uses the irregular plural of foot', {
      expect(inflector.pluralize('foot')).to.eq('feet');
    }

    it 'leaves deer alone', {
      expect(inflector.pluralize('deer')).to.eq('deer');
    }

    it 'leaves an uncountable word alone', {
      expect(inflector.pluralize('equipment')).to.eq('equipment');
    }

    it 'leaves an already plural irregular word alone', {
      expect(inflector.pluralize('people')).to.eq('people');
    }

    it 'pluralizes only the last dashed word', {
      expect(inflector.pluralize('line-item')).to.eq('line-items');
    }

    it 'pluralizes only the last underscored word', {
      expect(inflector.pluralize('lead_status')).to.eq('lead_statuses');
    }

    it 'applies an irregular to the last word of a compound', {
      expect(inflector.pluralize('sales-person')).to.eq('sales-people');
    }

    it 'keeps a capitalized irregular capitalized', {
      expect(inflector.pluralize('Person')).to.eq('People');
    }

    it 'returns an empty word unchanged', {
      expect(inflector.pluralize('')).to.eq('');
    }

    it 'turns ox into oxen', {
      expect(inflector.pluralize('ox')).to.eq('oxen');
    }

    it 'turns matrix into matrices', {
      expect(inflector.pluralize('matrix')).to.eq('matrices');
    }
  }

  describe 'singularize', {
    it 'drops the s from a regular word', {
      expect(inflector.singularize('leads')).to.eq('lead');
    }

    it 'turns ies into y', {
      expect(inflector.singularize('categories')).to.eq('category');
    }

    it 'drops es after ss', {
      expect(inflector.singularize('addresses')).to.eq('address');
    }

    it 'drops es from statuses', {
      expect(inflector.singularize('statuses')).to.eq('status');
    }

    it 'leaves a singular status alone', {
      expect(inflector.singularize('status')).to.eq('status');
    }

    it 'leaves a word ending in ss alone', {
      expect(inflector.singularize('address')).to.eq('address');
    }

    it 'turns ves into fe', {
      expect(inflector.singularize('knives')).to.eq('knife');
    }

    it 'turns lves into lf', {
      expect(inflector.singularize('shelves')).to.eq('shelf');
    }

    it 'uses the irregular singular of people', {
      expect(inflector.singularize('people')).to.eq('person');
    }

    it 'leaves an uncountable word alone', {
      expect(inflector.singularize('sheep')).to.eq('sheep');
    }

    it 'turns data into datum', {
      expect(inflector.singularize('data')).to.eq('datum');
    }

    it 'singularizes only the last dashed word', {
      expect(inflector.singularize('line-items')).to.eq('line-item');
    }

    it 'turns analyses into analysis', {
      expect(inflector.singularize('analyses')).to.eq('analysis');
    }

    it 'turns matrices into matrix', {
      expect(inflector.singularize('matrices')).to.eq('matrix');
    }

    it 'turns databases into database', {
      expect(inflector.singularize('databases')).to.eq('database');
    }
  }

  describe 'camelize', {
    it 'capitalizes a single word', {
      expect(inflector.camelize('tenant')).to.eq('Tenant');
    }

    it 'joins dashed words', {
      expect(inflector.camelize('line-item')).to.eq('LineItem');
    }

    it 'treats an underscore as part of the word', {
      expect(inflector.camelize('user_exercise')).to.eq('User_exercise');
    }
  }

  describe 'classify', {
    it 'singularizes and camelizes a plural name', {
      expect(inflector.classify('line-items')).to.eq('LineItem');
    }

    it 'classifies an irregular plural', {
      expect(inflector.classify('people')).to.eq('Person');
    }

    it 'classifies a consonant y plural', {
      expect(inflector.classify('categories')).to.eq('Category');
    }
  }

  describe 'underscore', {
    it 'snake_cases a camel-case name', {
      expect(inflector.underscore('PageTag')).to.eq('page_tag');
    }

    it 'strips the namespace', {
      expect(inflector.underscore('App::Models::LineItem')).to.eq('line_item');
    }

    it 'keeps an uppercase run together', {
      expect(inflector.underscore('HTTPRequest')).to.eq('http_request');
    }

    it 'turns a dash into an underscore', {
      expect(inflector.underscore('line-item')).to.eq('line_item');
    }
  }

  describe 'tableize', {
    it 'snake_cases and pluralizes a class name', {
      expect(inflector.tableize('LineItem')).to.eq('line_items');
    }

    it 'pluralizes an irregular class name', {
      expect(inflector.tableize('Person')).to.eq('people');
    }

    it 'pluralizes a consonant y class name', {
      expect(inflector.tableize('Category')).to.eq('categories');
    }

    it 'pluralizes a multi-word class name ending in status', {
      expect(inflector.tableize('LeadStatus')).to.eq('lead_statuses');
    }
  }

  describe 'foreign-key', {
    it 'snake_cases the base class name and adds _id', {
      expect(inflector.foreign-key('App::Models::UserExercise')).to.eq('user_exercise_id');
    }
  }

  describe 'app overrides', {
    context 'an irregular word', {
      before-each { inflector.inflections: { .irregular('octopus', 'octopi') } }

      it 'pluralizes with the override', {
        expect(inflector.pluralize('octopus')).to.eq('octopi');
      }

      it 'singularizes with the override', {
        expect(inflector.singularize('octopi')).to.eq('octopus');
      }
    }

    context 'an irregular word that was uncountable', {
      before-each { inflector.inflections: { .irregular('fish', 'fishes') } }

      it 'pluralizes with the override', {
        expect(inflector.pluralize('fish')).to.eq('fishes');
      }
    }

    context 'an uncountable word', {
      before-each { inflector.inflections: { .uncountable('aircraft') } }

      it 'leaves the plural alone', {
        expect(inflector.pluralize('aircraft')).to.eq('aircraft');
      }

      it 'leaves the singular alone', {
        expect(inflector.singularize('aircraft')).to.eq('aircraft');
      }
    }

    context 'a plural rule', {
      before-each { inflector.inflections: { .plural(rx:i/ ^ (cact) us $ /, '$0i') } }

      it 'pluralizes with the rule', {
        expect(inflector.pluralize('cactus')).to.eq('cacti');
      }
    }

    context 'a singular rule', {
      before-each { inflector.inflections: { .singular(rx:i/ ^ (cact) i $ /, '$0us') } }

      it 'singularizes with the rule', {
        expect(inflector.singularize('cacti')).to.eq('cactus');
      }
    }

    context 'an acronym', {
      before-each { inflector.inflections: { .acronym('API') } }

      it 'camelizes with the acronym', {
        expect(inflector.camelize('api-key')).to.eq('APIKey');
      }

      it 'classifies with the acronym', {
        expect(inflector.classify('api-keys')).to.eq('APIKey');
      }

      it 'underscores a class name that starts with the acronym', {
        expect(inflector.underscore('APIKey')).to.eq('api_key');
      }

      it 'underscores a class name that ends with the acronym', {
        expect(inflector.underscore('PublicAPI')).to.eq('public_api');
      }
    }

    context 'a rule that overrides a built-in rule', {
      before-each { inflector.inflections: { .plural(rx:i/ (stat) us $ /, '$0i') } }

      it 'uses the app rule', {
        expect(inflector.pluralize('status')).to.eq('stati');
      }
    }

    context 'two rules for the same word', {
      before-each {
        inflector.inflections: {
          .plural(rx:i/ (cact) us $ /, '$0uses');
          .plural(rx:i/ (cact) us $ /, '$0i');
        }
      }

      it 'uses the newer rule', {
        expect(inflector.pluralize('cactus')).to.eq('cacti');
      }
    }

    context 'a rule added outside an inflections block', {
      before-each { inflector.irregular('cow', 'kine') }

      it 'pluralizes with the rule', {
        expect(inflector.pluralize('cow')).to.eq('kine');
      }
    }
  }

  describe 'freezing', {
    it 'is not frozen before the first lookup', {
      expect(inflector.is-frozen).to.be-falsy;
    }

    context 'after a lookup', {
      before-each { inflector.pluralize('lead') }

      it 'is frozen', {
        expect(inflector.is-frozen).to.be-truthy;
      }

      it 'refuses an inflections block', {
        expect({ inflector.inflections: { .uncountable('aircraft') } }).to.raise-error(/'frozen'/);
      }

      it 'refuses an irregular word', {
        expect({ inflector.irregular('cow', 'kine') }).to.raise-error(/'frozen'/);
      }

      it 'refuses an uncountable word', {
        expect({ inflector.uncountable('aircraft') }).to.raise-error(/'frozen'/);
      }

      it 'refuses a plural rule', {
        expect({ inflector.plural(rx/ x $ /, 'xen') }).to.raise-error(/'frozen'/);
      }

      it 'refuses a singular rule', {
        expect({ inflector.singular(rx/ xen $ /, 'x') }).to.raise-error(/'frozen'/);
      }

      it 'refuses an acronym', {
        expect({ inflector.acronym('API') }).to.raise-error(/'frozen'/);
      }
    }

    context 'after an explicit freeze', {
      before-each { inflector.freeze }

      it 'refuses an inflections block', {
        expect({ inflector.inflections: { .uncountable('aircraft') } }).to.raise-error(/'frozen'/);
      }
    }
  }

  describe 'calls on the class', {
    it 'pluralize with the process-wide rules', {
      expect(Text::Inflector.pluralize('person')).to.eq('people');
    }

    it 'singularize with the process-wide rules', {
      expect(Text::Inflector.singularize('people')).to.eq('person');
    }

    it 'camelize with the process-wide rules', {
      expect(Text::Inflector.camelize('line-item')).to.eq('LineItem');
    }

    it 'classify with the process-wide rules', {
      expect(Text::Inflector.classify('line-items')).to.eq('LineItem');
    }

    it 'underscore with the process-wide rules', {
      expect(Text::Inflector.underscore('LineItem')).to.eq('line_item');
    }

    it 'tableize with the process-wide rules', {
      expect(Text::Inflector.tableize('LineItem')).to.eq('line_items');
    }

    it 'build a foreign key with the process-wide rules', {
      expect(Text::Inflector.foreign-key('LineItem')).to.eq('line_item_id');
    }

    context 'after a lookup', {
      before-each { Text::Inflector.pluralize('lead') }

      it 'report the process-wide rules as frozen', {
        expect(Text::Inflector.is-frozen).to.be-truthy;
      }

      it 'refuse an inflections block once the process-wide rules are frozen', {
        expect({ Text::Inflector.inflections: { .uncountable('aircraft') } }).to.raise-error(/'frozen'/);
      }

      it 'refuse an irregular word once the process-wide rules are frozen', {
        expect({ Text::Inflector.irregular('cow', 'kine') }).to.raise-error(/'frozen'/);
      }

      it 'refuse an uncountable word once the process-wide rules are frozen', {
        expect({ Text::Inflector.uncountable('aircraft') }).to.raise-error(/'frozen'/);
      }

      it 'refuse a plural rule once the process-wide rules are frozen', {
        expect({ Text::Inflector.plural(rx/ x $ /, 'xen') }).to.raise-error(/'frozen'/);
      }

      it 'refuse a singular rule once the process-wide rules are frozen', {
        expect({ Text::Inflector.singular(rx/ xen $ /, 'x') }).to.raise-error(/'frozen'/);
      }

      it 'refuse an acronym once the process-wide rules are frozen', {
        expect({ Text::Inflector.acronym('API') }).to.raise-error(/'frozen'/);
      }

      it 'return the class from freeze', {
        expect(Text::Inflector.freeze.is-frozen).to.be-truthy;
      }
    }
  }
}
