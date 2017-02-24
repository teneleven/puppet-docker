require 'spec_helper'

describe 'dockerbridge' do
  let(:facts) {
    {
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemrelease    => '16.04',
      :operatingsystemmajrelease => '16.04',
      :puppetversion             => '4.0',
      :lsbdistid                 => 'ubuntu',
      :lsbdistrelease            => '16.04',
      :lsbdistcodename           => 'xenial',
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

  context 'install docker' do
    let(:params) {
      {
        :install_docker => true,
      }
    }

    it { is_expected.to contain_class('docker') }
  end

  context 'inside container' do
    let(:facts) {
      {
        :is_container              => 1,
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Ubuntu',
        :operatingsystemrelease    => '16.04',
        :operatingsystemmajrelease => '16.04',
        :puppetversion             => '4.0',
        :lsbdistid                 => 'ubuntu',
        :lsbdistrelease            => '16.04',
        :lsbdistcodename           => 'xenial',
      }
    }

    let(:params) {
      {
        :install_docker => true,
      }
    }

    it { is_expected.to contain_class('dockerbridge::container::setup') }

    it { is_expected.to contain_class('docker').with(
      'service_enable' => false,
      # 'service_state'  => false,
    ) }
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
