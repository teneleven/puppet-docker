require 'spec_helper'

describe 'dockerbridge::provision' do
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

  describe 'docker' do
    let(:title) { 'docker-test' }
    let(:params) { { :provision_with => 'docker' } }

    it { is_expected.to contain_dockerbridge__run('docker-test').with(
      'options'  => { 'env' => [
        "FACTER_PROJECT_NAME=docker-test",
        "FACTER_APP_TYPE=",
        "FACTER_APP_HOSTS=docker-test.docker",
        "FACTER_APP_TARGET=docker-test",
        "FACTER_APP_PATH=docker-test",
      ]}
    ) }

    it { is_expected.to contain_dockerbridge__provision__docker('docker-test') }
  end

  describe 'docker-compose' do
    let(:title) { 'docker-compose-test' }
    let(:params) { { :provision_with => 'docker_compose' } }

    it { is_expected.to contain_dockerbridge__compose('docker-compose-test').with(
      'app_name' => 'docker-compose-test',
      'env' => [
        "COMPOSE_PROJECT_NAME=docker-compose-test",
        "COMPOSE_APP_TYPE=",
        "COMPOSE_APP_HOSTS=docker-compose-test.docker",
        "COMPOSE_APP_TARGET=docker-compose-test",
        "COMPOSE_APP_PATH=docker-compose-test",
      ]
    ) }

    # TODO this isn't working - perhaps because provision_with contains underscore?
    # it { is_expected.to contain_dockerbridge__provision__docker_compose('docker-test') }
  end

  describe 'shell' do
    let(:title) { 'shell-test' }
    let(:params) { { :provision_with => 'shell' } }

    it { is_expected.to contain_dockerbridge__provision__shell('shell-test').with(
      'env' => [
        "FACTER_PROJECT_NAME=shell-test",
        "FACTER_APP_TYPE=",
        "FACTER_APP_HOSTS=shell-test.docker",
        "FACTER_APP_TARGET=shell-test",
        "FACTER_APP_PATH=shell-test",
      ]
    ) }
  end

  describe 'extra options' do
    let(:title) { 'options-test' }
    let(:params) { { :provision_with => 'shell', :extra_options => {
      'app_name' => 'test',
    } } }

    it { is_expected.to contain_dockerbridge__provision__shell('options-test').with(
      'app_name' => 'test',
    ) }
  end
end
