module SmokeTest
  module Steps
    class BaseStep
      include Capybara::DSL

      attr_accessor :state

      def initialize(state)
        puts "Step:#{step_name}"
        @state = state
      end

      def validate!
        true
      end

      def complete_step
        raise NotImplementedError
      end

      protected

      def step_name
        self.class.name.split('::').last.gsub(/(?=[A-Z])/, ' ')
      end

      def mail_lookup
        MailLookup.new(state[:started_at])
      end

      def with_retries(attempts: 5, initial_delay: 2, max_delay: 30)
        delay = initial_delay
        result = nil
        attempts.times do
          result = yield
          break if result
          puts "waiting #{delay}s .."
          sleep delay
          delay = [max_delay, delay * 2].min
        end
        result
      end
    end
  end
end
