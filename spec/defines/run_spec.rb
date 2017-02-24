require 'spec_helper'

describe 'dockerbridge::run' do
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
      :puppet_dir                => 'puppet', # TODO this should likely be in params, not a fact
    }
  }

  context 'defaults' do
    let(:title) { 'ubuntu' }

    it { is_expected.to contain_docker__run('ubuntu').with(
      'hostname' => 'ubuntu',
      'image'    => 'base',
      'env'      => ['FACTER_is_container=1'],
      'volumes'  => ['puppet:/puppet'],
    ) }
  end

  context 'docker options' do
    let(:title) { 'ubuntu' }

    let(:params) {
      { :options => {
        'image' => 'ubuntu',
      } }
    }

    it { is_expected.to contain_docker__run('ubuntu').with(
      'image' => 'ubuntu',
    ) }
  end

  context 'docker volumes' do
    let(:title) { 'ubuntu' }

    let(:params) {
      { :options => {
        'volumes' => ['www:/var/www']
      } }
    }

    it { is_expected.to contain_docker__run('ubuntu').with(
      'volumes' => ['puppet:/puppet', 'www:/var/www'],
    ) }
  end

  context 'docker env' do
    let(:title) { 'ubuntu' }

    let(:params) {
      { :options => {
        'env' => ['HOME=/var/www']
      } }
    }

    it { is_expected.to contain_docker__run('ubuntu').with(
      'env' => ['FACTER_is_container=1', 'HOME=/var/www'],
    ) }
  end
end
