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

  context 'ubuntu image' do
    let(:params) {
      {
        :images => { 'ubuntu' => { 'image' => 'ubuntu' } },
      }
    }

    it { is_expected.to contain_docker__image('ubuntu').with(
      'image' => 'ubuntu'
    ) }
  end

  context 'ubuntu container' do
    let(:params) {
      {
        :run        => ['ubuntu'],
        :containers => { 'ubuntu' => { 'image' => 'ubuntu' } },
      }
    }

    it { is_expected.to contain_dockerbridge__run('ubuntu').with(
      'options' => { 'image' => 'ubuntu' }
    ) }
  end

  context 'docker-compose' do
    let(:params) {
      {
        :compose => { 'ubuntu' => 'test' },
      }
    }

    it { is_expected.to contain_dockerbridge__compose('ubuntu').with(
      { 'app_type' => 'test' }
    ) }
  end

  context 'provision' do
    let(:params) {
      {
        :provision => { 'ubuntu' => 'test' },
      }
    }

    it { is_expected.to contain_dockerbridge__provision('ubuntu').with(
      { 'app' => 'test' }
    ) }
  end
end
