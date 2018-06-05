require 'spec_helper'

describe 'scaleio::gui_server' do
  let(:facts) {{
    :osfamily => 'Debian'
  }}

  it { is_expected.to contain_class('scaleio::gui_server')}

  describe 'when ensure is absent' do
    let :params do
      { :ensure   => 'absent' }
    end
    it 'removes gui' do
      is_expected.to contain_scaleio__package('gui').with_ensure('absent')
    end
  end

  describe 'when ensure = present' do

    let :params do
      { :ensure   => 'present' }
    end
    it 'contains install common packages for GUI' do
      is_expected.to contain_scaleio__common_server('install common packages for GUI').with(
        :ensure_java=>'present')
    end
    it 'installs utilities' do
      is_expected.to contain_package('numactl').with_ensure('installed')
      is_expected.to contain_package('libaio1').with_ensure('installed')
      is_expected.to contain_package('wget').with_ensure('installed')
    end
    it 'runs java8 repo' do
      is_expected.to contain_exec('add java8 repo').with(
        :command     => 'add-apt-repository ppa:webupd8team/java && apt-get update')
    end
    it 'java license accepting step 1' do
      is_expected.to contain_exec('java license accepting step 1').with(
        :command     => 'echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections')
    end
    it 'java license accepting step 2' do
      is_expected.to contain_exec('java license accepting step 2').with(
        :command     => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections')
    end
    context 'with pkg_ftp' do
      let (:params) {{
        :pkg_ftp => 'ftp://ftp',
      }}
      it 'installs gui' do
        is_expected.to contain_package('oracle-java8-installer').with_ensure('installed')
        is_expected.to contain_scaleio__package('gui').with_ensure('installed')
        is_expected.to contain_file('ensure get_package.sh for gui').with(
          :ensure => 'present',
          :path   => '/root/get_package_gui.sh',
          :source => 'puppet:///modules/scaleio/get_package.sh',
          :mode   => '0700',
          :owner  => 'root',
          :group  => 'root')
        is_expected.to contain_exec('get_package gui').with(
          :command => '/root/get_package_gui.sh ftp://ftp/Ubuntu gui',
          :path    => '/bin:/usr/bin')
        is_expected.to contain_package('EMC_ScaleIO_GUI').with(
          :ensure   => 'installed',
          :source   => '/tmp/gui/gui.deb',
          :parser => 'dpkg')
      end
    end
  end
end