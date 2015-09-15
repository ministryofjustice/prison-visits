RSpec.shared_examples 'a mailer that ensures content transfer encoding is quoted printable' do
  specify { expect(described_class.ancestors).to include EnsureQuotedPrintable }
end
