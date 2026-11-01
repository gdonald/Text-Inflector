use lib 'lib';
use BDD::Behave;
use Text::Inflector;

Text::Inflector.inflections: {
  .irregular('cow', 'kine');
  .uncountable('aircraft');
}

describe 'process-wide rules added before the first lookup', {
  it 'pluralize an irregular word', {
    expect(Text::Inflector.pluralize('cow')).to.eq('kine');
  }

  it 'singularize an irregular word', {
    expect(Text::Inflector.singularize('kine')).to.eq('cow');
  }

  it 'leave an uncountable word alone', {
    expect(Text::Inflector.pluralize('aircraft')).to.eq('aircraft');
  }

  it 'change the table name of a class', {
    expect(Text::Inflector.tableize('Cow')).to.eq('kine');
  }

  it 'leave a separate instance on the built-in rules', {
    expect(Text::Inflector.new.pluralize('cow')).to.eq('cows');
  }
}
