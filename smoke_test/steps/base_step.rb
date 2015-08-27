module SmokeTest
  module Steps
    class BaseStep
      include Capybara::DSL

      attr_accessor :state

      def initialize(state)
        puts "Step:#{step_name}"
        @state = state
      end

      def assert_validity!
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
    end
  end
end
