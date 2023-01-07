# frozen_string_literal: true

namespace :ds do
  desc 'Removes all project budgets'
  task reset_budgets: [:environment] do
    puts "Resetting #{Project.count} project budget(s)..."
    Project.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('projects')
  end
end
