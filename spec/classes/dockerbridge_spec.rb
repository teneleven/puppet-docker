require 'spec_helper'

describe 'dockerbridge' do
  let(:facts) {
    {
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemrelease    => '16.04',
      :operatingsystemmajrelease => '16.04',
      :puppetversion             => '4.0',
    }
  }

  context 'basic' do
    let(:params) {
      {
        :provision  => {},
        :images     => {},
        :run        => {},
        :containers => {},
      }
    }

    it { is_expected.to contain_class('dockerbridge') }
  end
end
