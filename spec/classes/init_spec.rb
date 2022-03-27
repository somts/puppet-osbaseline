require 'spec_helper'
describe 'osbaseline', type: :class do
  shared_examples 'Kernel Linux' do
    it_behaves_like 'Kernel UNIX-like FOSS'

    it do is_expected.to contain_class('logrotate') end
    it do is_expected.to contain_class('puppet_agent') end
  end

  shared_examples 'Kernel UNIX-like FOSS' do # FreeBSD, Linux
    it_behaves_like 'with manage_package_manager'
    it do is_expected.to contain_class('git') end
    it do is_expected.to contain_class('ntp') end
    it do is_expected.to contain_class('rsync') end

    context 'with git_configs set' do
      let :params do
        {
          git_configs: {
            'http.proxy'  => { 'value' => 'http://proxy.example.com:3128/' },
            'https.proxy' => { 'value' => 'http://proxy.example.com:3128/' }
          }
        }
      end

      it do
        is_expected.to contain_git__config('http.proxy').with(
          value: 'http://proxy.example.com:3128/',
          scope: 'system',
        )
      end
      it do
        is_expected.to contain_git__config('https.proxy').with(
          value: 'http://proxy.example.com:3128/',
          scope: 'system',
        )
      end
    end

    context 'with rsync excluded' do
      let :params do
        { classes_exclude: ['rsync'] }
      end

      it do is_expected.not_to contain_class('rsync') end
      it do is_expected.to contain_class('git') end
      it do is_expected.to contain_class('ntp') end
    end
  end

  shared_examples 'OS family Darwin' do
    it_behaves_like 'with manage_package_manager'
    it do is_expected.to contain_class('homebrew') end
  end

  shared_examples 'OS family Debian' do
    it_behaves_like 'Kernel Linux'
    it do is_expected.to contain_class('apt') end
  end

  shared_examples 'OS family FreeBSD' do
    it_behaves_like 'Kernel UNIX-like FOSS'

    it do is_expected.to contain_package('bash') end
    it do is_expected.to contain_package('bash-completion') end
    it do is_expected.to contain_mount('/dev/fd') end

    it do is_expected.to contain_file('/home').with_target('usr/home') end
    it do is_expected.to contain_file('/usr/home').with_ensure('directory') end

    it do is_expected.to contain_class('pkgng') end
    it do
      is_expected.to contain_cron('freebsd-update cron').with_command(
        '/usr/sbin/freebsd-update cron',
      )
    end
  end

  shared_examples 'OS family RedHat' do
    it_behaves_like 'Kernel Linux'

    it do is_expected.not_to contain_class('epel') end
    it do is_expected.to contain_class('yum') end
    it do is_expected.to contain_package('epel-release') end
    it do is_expected.to contain_class('selinux') end
  end

  shared_examples 'OS family Windows' do
    it_behaves_like 'with manage_package_manager'
    it do is_expected.to contain_class('puppet_agent') end

    context 'with puppet_agent excluded' do
      let :params do
        { classes_exclude: ['puppet_agent'] }
      end

      it do is_expected.not_to contain_class('puppet_agent') end
    end
  end

  shared_examples 'OS name OracleLinux 7' do
    it do
      is_expected.to contain_package('epel-release').with(
        name: 'oracle-epel-release-el7',
        ensure: 'present',
      ).that_comes_before('Class[yum]')
    end
  end

  shared_examples 'OS name OracleLinux 8' do
    it do
      is_expected.to contain_package('epel-release').with(
        name: 'oracle-epel-release-el8',
        ensure: 'present',
      ).that_comes_before('Class[yum]')
    end
  end

  shared_examples 'with manage_package_manager' do # Darwin, FreeBSD, Linux
    it do is_expected.not_to contain_class('wget') end

    context 'with packages set' do
      let :params do
        { packages: ['foo', 'bar', 'baz'] }
      end

      it do is_expected.to contain_package('foo') end
      it do is_expected.to contain_package('bar') end
      it do is_expected.to contain_package('baz') end
    end

    context 'with packages and packages_removed set' do
      let :params do
        { packages: ['foo'], packages_removed: ['bar', 'baz'] }
      end

      it do is_expected.to contain_package('foo') end
      it do
        is_expected.to contain_package('bar').with_ensure('absent')
      end
      it do
        is_expected.to contain_package('baz').with_ensure('absent')
      end
    end
  end

  shared_examples 'module classes' do
    it do is_expected.to compile.with_all_deps end
    it do is_expected.to create_class('osbaseline') end
    it do
      is_expected.to create_class(
        'osbaseline::accounts',
      ).that_comes_before('Class[osbaseline::package_manager]')
    end
    it do
      is_expected.to create_class(
        'osbaseline::package_manager',
      ).that_comes_before('Class[osbaseline::resources]')
    end
    it do is_expected.to create_class('osbaseline::resources') end
  end

  on_supported_os.sort.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it_behaves_like 'module classes'

      case os_facts[:osfamily]
      when 'Darwin'
        it_behaves_like 'OS family Darwin'
      when 'Debian'
        it_behaves_like 'OS family Debian'
      when 'FreeBSD'
        it_behaves_like 'OS family FreeBSD'
      when 'RedHat'
        case os_facts[:os]['name']
        when 'OracleLinux'
          case os_facts[:os]['release']['major']
          when '7' then it_behaves_like 'OS name OracleLinux 7'
          when '8' then it_behaves_like 'OS name OracleLinux 8'
          end
        end
        it_behaves_like 'OS family RedHat'
      when 'windows'
        it_behaves_like 'OS family Windows'
      end

      # Test for Open VM Tools on certain kernels
      case os_facts[:kernel]
      when 'FreeBSD', 'Linux'
        context 'vmware' do
          let :facts do
            os_facts.merge(virtual: 'vmware')
          end

          it do
            is_expected.to create_class('openvmtools')
          end
        end

        context 'physical' do
          let :facts do
            os_facts.merge(virtual: 'physical')
          end

          it do
            is_expected.not_to contain_class('openvmtools')
          end
        end
      end
    end
  end
end
