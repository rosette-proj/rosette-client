# encoding: UTF-8

require 'pry-nav'

require 'rspec'
require 'rosette/client'
require 'helpers/fake_terminal'
require 'tmp-repo'

RSpec.configure do |config|
  # config goes here

  def sample_diff(commit_id)
    {
      'added' => [{
        'key' => "I'm a little teapot",
        'meta_key' => 'about.training.teapot',
        'file' => 'config/locales/en.yml',
        'commit_id' => commit_id
      }],

      'removed' => [{
        'key' => 'The green albatross flitters in the moonlight',
        'meta_key' => 'animals.birds.albatross.message',
        'file' => 'config/locales/en.yml',
        'commit_id' => commit_id
      }],

      'modified' => [{
        'key' => 'Purple eggplants make delicious afternoon snacks',
        'old_key' => 'Blue eggplants make wonderful evening meals',
        'meta_key' => 'foods.vegetables.eggplant.snack_message',
        'file' => 'config/locales/en.yml',
        'commit_id' => commit_id
      }, {
        'key' => 'The Seattle Seahawks rock',
        'old_key' => 'The Seattle Seahawks rule',
        'meta_key' => 'sports.teams.football.best',
        'file' => 'config/locales/en.yml',
        'commit_id' => commit_id
      }]
    }
  end
end
