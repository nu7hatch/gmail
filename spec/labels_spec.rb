require 'spec_helper'

describe Gmail::Labels do
  context '#localize' do
    context 'when given the XLIST flag ' do
      [:Inbox, :Allmail, :Drafts, :Sent, :Trash, :Important, :Spam].each do |flag|
        context flag do
          it 'localizes into the appropriate label' do
            localized = ""
            mock_client { |client| localized = client.labels.localize(flag) }
            localized.should be_a_kind_of(String)
            localized.should match(/\[Gmail|Google Mail\]|Inbox/i)
          end
        end
      end
    end
  end
end
    
