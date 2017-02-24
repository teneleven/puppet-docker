require 'spec_helper'

describe 'dockerbridge::compose' do
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

  let(:title) { 'website' }

  describe 'simple' do
    it { is_expected.to contain_exec('compose-name-website').only_with(
      'command'     => 'docker-compose -f %{::volume_dir}/devops/apps/website/services.yaml up -d',
      'provider'    => 'shell',
      #'environment' => ['COMPOSE_PROJECT_NAME=website', 'COMPOSE_APP_TYPE='],
      'environment' => ['COMPOSE_PROJECT_NAME=website'],
      'onlyif'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/website/services.yaml',
    ) }

    it { is_expected.to contain_exec('compose-default-website').only_with(
      'command'     => 'docker-compose -f %{::volume_dir}/devops/apps/default/services.yaml up -d',
      'provider'    => 'shell',
      #'environment' => ['COMPOSE_PROJECT_NAME=website', 'COMPOSE_APP_TYPE='],
      'environment' => ['COMPOSE_PROJECT_NAME=website'],
      'unless'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/website/services.yaml || /usr/bin/test -e %{::volume_dir}/devops/apps//services.yaml || /usr/bin/test -e %{::volume_dir}/devops/apps/default//services.yaml'
    ) }
  end

  describe 'env variables' do
    let(:params) {
      {
        :env => ['COMPOSE_APP_TYPE=test']
      }
    }

    it { is_expected.to contain_exec('compose-name-website').only_with(
      'command'     => 'docker-compose -f %{::volume_dir}/devops/apps/website/services.yaml up -d',
      'provider'    => 'shell',
      'environment' => ['COMPOSE_PROJECT_NAME=website', 'COMPOSE_APP_TYPE=test'],
      'onlyif'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/website/services.yaml',
    ) }
  end

  describe 'app type' do
    let(:params) {
      {
        :app_type => 'test'
      }
    }

    it { is_expected.to contain_exec('compose-type-website-test').only_with(
      'command'     => 'docker-compose -f %{::volume_dir}/devops/apps/test/services.yaml up -d',
      'provider'    => 'shell',
      #'environment' => ['COMPOSE_PROJECT_NAME=website', 'COMPOSE_APP_TYPE='],
      'environment' => ['COMPOSE_PROJECT_NAME=website'],
      'unless'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/website/services.yaml',
      'onlyif'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/test/services.yaml',
    ) }

    it { is_expected.to contain_exec('compose-type-fallback-website-test').only_with(
      'command'     => 'docker-compose -f %{::volume_dir}/devops/apps/default/test/services.yaml up -d',
      'provider'    => 'shell',
      #'environment' => ['COMPOSE_PROJECT_NAME=website', 'COMPOSE_APP_TYPE='],
      'environment' => ['COMPOSE_PROJECT_NAME=website'],
      'unless'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/website/services.yaml || /usr/bin/test -e %{::volume_dir}/devops/apps/test/services.yaml',
      'onlyif'      => '/usr/bin/test -e %{::volume_dir}/devops/apps/default/test/services.yaml',
    ) }
  end
end
