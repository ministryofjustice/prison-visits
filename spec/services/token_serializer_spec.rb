require 'rails_helper'

RSpec.describe TokenSerializer do
  subject { described_class.new('a' * 88) }

  context 'a current token' do
    let(:visit) { Visit.new(visit_id: 'ABC123') }

    context 'round-trip encryption and decryption' do
      subject {
        super().decrypt_and_verify(super().encrypt_and_sign(visit))
      }

      it { is_expected.to be_a(Visit) }
      it { is_expected.to have_attributes(visit_id: 'ABC123') }
    end

    context 'when corrupted' do
      it 'raises an exception' do
        expect {
          subject.decrypt_and_verify(subject.encrypt_and_sign(visit) + 'x')
        }.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end

  context 'an old token' do
    let(:ciphertext) {
      %w[
        M3JoYWEyWFJ2RHBVNUtHalErNTBqbEhiejVRckR6YkdBZlZMcDdLM01KcVho
        dTBhd05mTGJoc2thTzFjd0hRbEpMUUFWYTZoakMvWldIMVo3K2RQT0UvRjJy
        Z01Fd04rUXo1Z1NBRjM0Vi9janZWY3RoZEp1R28xWHcxUG1KaE45eDNwTEM4
        WkZVWEF4dksxMXpvR2dlWmZlQ0FSK2NveFlzTktrRktpOCszYStoTWdaSmpw
        alJHWkFJUWJJbTRXYmdMaUV3U3ZWRmsrWkxUd2E1bUltWVdJckhiZC9wdWJQ
        UHRYNmFNbzJwUkwwcmZZRG5YdVRkQ2VxN3BCQnJvdjM4ajVOSlU5ZmM5NC9w
        N0ROSGQxeXlpSE5BTTRSNDRSQ2ZNOUZVb2NIRi9yZDBUeE1TV01sTDdzbG9u
        elNoOVdWb01zZzhUa3YvdnJDd2srK1dsU0pxLzFHNnMxbzNxVVBNY3NNOHRn
        c0FRdXRQTnRFSDFOWjJxcUJtdFFoUkJvSXBBWUh2QlVTNUl6SUJUNncvTEhL
        cXVNVGVBeVpQTXlCRW84a1ZhSGxMN0lTSmZvdTdzRm13bUUzb2IyWDVoQTc4
        azVzZzBQSmJlck9QRktYSzFsWkI3R0oyeHhUY0VJNm9vbkE2Tkx3Y2U4NnRO
        U1ZUSlg4RVJ6TFVlMEZMeVZwaVBJVHN2SFcrR3hHejgyZzJPRS9zUVVyVXp0
        dnlOeWhyblQ2ZnJjNmFNMzhLYzVZUENCYkJrT1A0OHZHa2MvQWlDYVBGU2ZI
        Tkgrb053SndKYTdWcmRPdTJ3dDNOSE9hbkpTOWdhOXhNaEZ4YUxHSWErZGhI
        SVo5NnhhbEJnNjZERmVwem1CV21GZ2ZTMUYvU09KRmNPeGxsbFFZRVBGZk41
        dnYwLzJ2Tmc9LS1zMGhXYmZUQklWVW5XVWIwUzJKYnFBPT0=--0942e2bc53
        adf866eb0e82ceb3ce266b88fbbba3
      ].join('')
    }

    subject { super().decrypt_and_verify(ciphertext) }

    it { is_expected.to be_a(Visit) }
    it { is_expected.to have_attributes(visit_id: '2e3f6d7b1b467cf7ba49072b89d04922') }
  end
end
