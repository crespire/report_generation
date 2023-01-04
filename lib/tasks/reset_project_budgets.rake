# frozen_string_literal: true

namespace :ds do
  desc 'Removes all project budgets'
  task reset_projects: [:environment] do
    puts "Removing #{Project.count} project record(s)..."
    Project.delete_all
  end
end