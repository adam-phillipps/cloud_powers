require 'workflow'
require 'byebug'

class Tz
  include Workflow
  byebug
  workflow do
    state :new do
      event :submit, :transitions_to => :awaiting_review
    end
    state :awaiting_review do
      event :review, :transitions_to => :being_reviewed
    end
    state :being_reviewed do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :accepted
    state :rejected
  end
  puts 'yo'

  byebug
  def review
    byebug
    puts 'wow'
  end

  def accept!
    byebug
    puts 'accepted'
  end

  def reject
    byebug
    puts 'reject'
  end
end

if __FILE__
  byebug
  tz = Tz.new
end
