require 'spec_helper'

describe 'raspberry_phoronix::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  
  describe command('phoronix-test-suite') do
    its(:exit_status) { should eq 0 }
  end
end
